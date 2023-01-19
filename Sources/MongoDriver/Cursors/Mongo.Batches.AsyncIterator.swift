extension Mongo.Batches
{
    public final
    class AsyncIterator
    {
        @usableFromInline
        var cursor:Mongo.CursorIterator?
        @usableFromInline
        var first:[BatchElement]?

        init(cursor:Mongo.CursorIterator?,
            first:[BatchElement])
        {
            self.cursor = cursor
            self.first = first.isEmpty ? nil : first
        }
        deinit
        {
            guard case nil = self.cursor
            else
            {
                fatalError("unreachable (deinitialized while cursor still open!)")
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

        guard let cursor:Mongo.CursorIterator = self.cursor
        else
        {
            return nil
        }

        let next:Mongo.Cursor<BatchElement>
        do
        {
            next = try await cursor.get(more: BatchElement.self)
        }
        catch let error
        {
            let _:Mongo.KillCursorsResponse? = try? await cursor.kill()
            self.cursor = nil
            throw error
        }
        
        switch next.id
        {
        case cursor.id?:
            return next.elements
        
        case let id?:
            let _:Mongo.KillCursorsResponse? = try? await cursor.kill()
            self.cursor = nil
            throw Mongo.CursorIdentifierError.init(invalid: id)
        
        case nil:
            self.cursor = nil
            return next.elements.isEmpty ? nil : next.elements
        }
    }
}
