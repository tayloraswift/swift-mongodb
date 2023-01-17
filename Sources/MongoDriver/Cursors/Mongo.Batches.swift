import Durations
import MongoSchema

extension Mongo
{
    public
    struct Batches<BatchElement> where BatchElement:MongoDecodable
    {
        public
        let iterator:AsyncIterator

        init(iterator:AsyncIterator)
        {
            self.iterator = iterator
        }
    }
}
extension Mongo.Batches
{
    public
    var cursor:Mongo.CursorIterator<BatchElement>?
    {
        self.iterator.cursor
    }
}
extension Mongo.Batches
{
    @usableFromInline static
    func create(preference:Mongo.ReadPreference,
        lifespan:Mongo.CursorLifespan,
        timeout:Mongo.OperationTimeout,
        initial:Mongo.Cursor<BatchElement>,
        stride:Int,
        pinned:
        (
            connection:Mongo.Connection,
            session:Mongo.Session
        ),
        pool:Mongo.ConnectionPool) -> Self
    {
        let iterator:AsyncIterator
        if  let cursor:Mongo.CursorIdentifier = initial.id
        {
            iterator = .init(timeout: timeout, cursor: .init(cursor: cursor,
                    preference: preference,
                    namespace: initial.namespace,
                    lifespan: lifespan,
                    stride: stride,
                    pinned: pinned,
                    pool: pool),
                first: initial.elements)
        }
        else
        {
            iterator = .init(timeout: timeout, cursor: nil,
                first: initial.elements)
            /// if cursor is already closed, destroy the connection
            pool.destroy(pinned.connection)
        }
        return .init(iterator: iterator)
    }
    @usableFromInline
    func destroy() async throws
    {
        if  let cursor:Mongo.CursorIterator = self.iterator.cursor
        {
            self.iterator.cursor = nil
            let _:Mongo.KillCursorsResponse = try await cursor.pinned.session.run(
                command: Mongo.KillCursors.init([cursor.id],
                    collection: cursor.namespace.collection),
                against: cursor.namespace.database,
                over: cursor.pinned.connection,
                on: cursor.preference,
                //  ``KillCursors`` always refreshes the timeout
                by: self.iterator.timeout.deadline())
            cursor.pool.destroy(cursor.pinned.connection)
        }
    }
}


// extension Mongo.Batches
// {
//     @inlinable public
//     var database:Mongo.Database
//     {
//         self.namespace.database
//     }
//     @inlinable public
//     var collection:Mongo.Collection
//     {
//         self.namespace.collection
//     }
// }
extension Mongo.Batches:AsyncSequence
{
    public
    typealias Element = [BatchElement]

    @inlinable public
    func makeAsyncIterator() -> AsyncIterator
    {
        self.iterator
    }
}
