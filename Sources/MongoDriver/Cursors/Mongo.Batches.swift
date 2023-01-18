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
    var cursor:Mongo.CursorIterator?
    {
        self.iterator.cursor
    }
}
extension Mongo.Batches
{
    @usableFromInline static
    func create(preference:Mongo.ReadPreference,
        lifecycle:Mongo.CursorLifecycle,
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
            iterator = .init(cursor: .init(cursor: cursor,
                    preference: preference,
                    namespace: initial.namespace,
                    lifecycle: lifecycle,
                    timeout: timeout,
                    stride: stride,
                    pinned: pinned,
                    pool: pool),
                first: initial.elements)
        }
        else
        {
            iterator = .init(cursor: nil,
                first: initial.elements)
            /// if cursor is already closed, destroy the connection
            pool.destroy(pinned.connection)
        }
        return .init(iterator: iterator)
    }
    @usableFromInline
    func destroy() async
    {
        if let cursor:Mongo.CursorIterator = self.iterator.cursor
        {
            let _:Mongo.KillCursorsResponse? = try? await cursor.kill()
            cursor.pool.destroy(cursor.pinned.connection)
            self.iterator.cursor = nil
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
