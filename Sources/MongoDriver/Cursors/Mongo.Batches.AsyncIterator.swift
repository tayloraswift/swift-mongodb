extension Mongo.Batches
{
    public final
    class AsyncIterator
    {
        /// The operation timeout used for ``KillCursors``, and the default
        /// operation timeout used for ``GetMore`` for tailable cursors without
        /// an explicit timeout set.
        @usableFromInline
        let timeout:Mongo.OperationTimeout
        @usableFromInline
        var cursor:Mongo.CursorIterator<BatchElement>?
        @usableFromInline
        var first:[BatchElement]?

        init(timeout:Mongo.OperationTimeout,
            cursor:Mongo.CursorIterator<BatchElement>?,
            first:[BatchElement])
        {
            self.timeout = timeout
            self.cursor = cursor
            self.first = first.isEmpty ? nil : first
        }
        deinit
        {
            guard case nil = self.cursor
            else
            {
                fatalError("unreachable (deinitialized while connection still checked-out!)")
            }
        }
    }
}
extension Mongo.Batches.AsyncIterator:AsyncIteratorProtocol
{
    @inlinable public
    func next() async throws -> [BatchElement]?
    {
        if let first:[BatchElement] = self.first
        {
            self.first = nil
            return first
        }

        guard let cursor:Mongo.CursorIterator<BatchElement> = self.cursor
        else
        {
            return nil
        }

        let next:Mongo.Cursor<BatchElement> = try await cursor.pinned.session.run(
            command: Mongo.GetMore<BatchElement>.init(cursor: cursor.id,
                collection: cursor.namespace.collection,
                timeout: cursor.lifespan._timeout,
                count: cursor.stride),
            against: cursor.namespace.database,
            over: cursor.pinned.connection,
            on: cursor.preference,
            by: cursor.lifespan.deadline(default: self.timeout))
        
        switch next.id
        {
        case cursor.id?:
            return next.elements
        
        case let id?:
            throw Mongo.CursorIdentifierError.init(invalid: id)
        
        case nil:
            cursor.pool.destroy(cursor.pinned.connection)
            self.cursor = nil
            return next.elements.isEmpty ? nil : next.elements
        }
    }
}
