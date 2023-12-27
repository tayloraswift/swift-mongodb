extension Mongo
{
    /// Stores information about a delete operation.
    @frozen public
    struct Deletions:Error, Equatable, Sendable
    {
        public
        let deleted:Int

        @inlinable public
        init(deleted:Int)
        {
            self.deleted = deleted
        }
    }
}
