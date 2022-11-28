import MongoSchema

extension Mongo
{
    @frozen public
    struct Stream<BatchElement> where BatchElement:MongoDecodable
    {
        @usableFromInline private(set)
        var manager:StreamManager?
        @usableFromInline private(set)
        var first:[BatchElement]?

        @inlinable public
        init(manager:StreamManager?, first:[BatchElement])
        {
            self.manager = manager
            self.first = first
        }
    }
}
extension Mongo.Stream
{
    /// Returns the cursor associated with this stream, or [`nil`]()
    /// if the cursor has been exhausted. Cursor exhaustion is not the
    /// same thing as stream exhaustion; if a query returns a single
    /// batch, the cursor will be exhausted but the stream will contain
    /// buffered elements.
    public
    var cursor:(id:Mongo.CursorIdentifier, namespace:Mongo.Namespace)?
    {
        self.manager.map { ($0.cursor, $0.namespace) }
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
    @inlinable public mutating
    func next() async throws -> [BatchElement]?
    {
        if  let first:[BatchElement] = self.first
        {
            self.first = nil
            return first
        }
        guard let manager:Mongo.StreamManager = self.manager
        else
        {
            return nil
        }
        guard let batch:[BatchElement] = try await manager.get(more: BatchElement.self)
        else
        {
            self.manager = nil
            return nil
        }
        if manager.cursor == .none
        {
            self.manager = nil
            return batch.isEmpty ? nil : batch
        }
        else
        {
            return batch
        }
    }
}

extension Mongo.Session
{
    @inlinable public
    func run<Query>(query:Query, 
        against database:Mongo.Database) async throws -> Mongo.Stream<Query.Element>
        where Query:MongoStreamableCommand
    {
        let batching:Int = query.batching
        let timeout:Mongo.Milliseconds? = query.timeout
        let cursor:Mongo.Cursor<Query.Element> = try await self.run(command: query,
            against: database)
        return .init(manager: .init(session: self, cursor: cursor.id,
                namespace: cursor.namespace,
                batching: batching,
                timeout: timeout),
            first: cursor.elements)
    }
}
