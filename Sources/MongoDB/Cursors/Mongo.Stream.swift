import BSONDecoding
import Durations
import MongoSchema

extension Mongo
{
    @frozen public
    struct Stream<BatchElement> where BatchElement:MongoDecodable
    {
        public
        let namespace:Namespace
        public
        let session:MutableSession
        public
        let timeout:Milliseconds?
        public
        let stride:Int

        @_Boxed<Cursor<BatchElement>.State>
        public
        var cursor:Cursor<BatchElement>.State

        @usableFromInline
        init(session:MutableSession,
            initial:Cursor<BatchElement>,
            timeout:Milliseconds?,
            stride:Int)
        {
            self._cursor = .init(wrappedValue: initial.state)

            self.namespace = initial.namespace
            self.session = session
            self.timeout = timeout
            self.stride = stride
        }
    }
}
extension Mongo.Stream
{
    @inlinable public
    var database:Mongo.Database
    {
        self.namespace.database
    }
    @inlinable public
    var collection:Mongo.Collection
    {
        self.namespace.collection
    }
}
extension Mongo.Stream:AsyncSequence, AsyncIteratorProtocol
{
    public
    typealias Element = [BatchElement]

    @inlinable public
    func makeAsyncIterator() -> Self
    {
        self
    }
    @inlinable public
    func next() async throws -> [BatchElement]?
    {
        if      let first:[BatchElement] = self.cursor.pop()
        {
            return first
        }
        else if let next:Mongo.CursorIdentifier = .init(self.cursor.next)
        {
            let cursor:Mongo.Cursor<BatchElement> = try await self.session.run(
                command: Mongo.GetMore<BatchElement>.init(cursor: next,
                    collection: self.collection,
                    timeout: self.timeout,
                    count: self.stride),
                against: self.database)
            
            self.cursor.next = cursor.next
            return cursor.batch
        }
        else
        {
            return nil
        }
    }
}
extension Mongo.Stream
{
    public
    func `deinit`() async throws
    {
        if let cursor:Mongo.CursorIdentifier = .init(self.cursor.next)
        {
            let _:Mongo.KillCursors.Response = try await session.run(
                command: Mongo.KillCursors.init([cursor], collection: self.collection),
                against: database)
        }
    }
}

extension Mongo.MutableSession
{
    @inlinable public
    func run<Query, Success>(query:Query, against database:Mongo.Database,
        with consumer:(Mongo.Stream<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoStreamableCommand
    {
        let stream:Mongo.Stream<Query.Element> = .init(session: self,
            initial: try await self.run(command: query,
                against: database),
            timeout: query.timeout,
            stride: query.stride)
        let result:Result<Success, any Error>
        do
        {
            result = .success(try await consumer(stream))
        }
        catch let error
        {
            result = .failure(error)
        }
        try await stream.deinit()
        return try result.get()
    }
}
