import Durations
import BSONDecoding

extension Mongo
{
    public
    struct Batches<BatchElement> where BatchElement:BSONDocumentDecodable & Sendable
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
        )) -> Self
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
                    pinned: pinned),
                first: initial.elements)
        }
        else
        {
            // connection will be dropped and returned to its pool automatically.
            iterator = .init(cursor: nil, first: initial.elements)
        }
        return .init(iterator: iterator)
    }
    @usableFromInline
    func destroy() async
    {
        if  let cursor:Mongo.CursorIterator = self.iterator.cursor
        {
            let _:Mongo.KillCursorsResponse? = try? await cursor.kill()
            self.iterator.cursor = nil
        }
    }
}

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
