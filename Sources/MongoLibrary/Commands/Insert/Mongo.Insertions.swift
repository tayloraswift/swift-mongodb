extension Mongo
{
    /// Stores information about an insert operation.
    @frozen public
    struct Insertions:Error, Equatable, Sendable
    {
        public
        let inserted:Int

        @inlinable public
        init(inserted:Int)
        {
            self.inserted = inserted
        }
    }
}
