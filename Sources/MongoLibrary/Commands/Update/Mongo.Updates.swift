extension Mongo
{
    /// Stores information about an update operation.
    @frozen public
    struct Updates<ID>:Error
    {
        public
        let selected:Int
        /// The number of documents modified during the operation. This may be
        /// less than the number of documents ``selected``.
        public
        let modified:Int
        public
        let upserted:[Upsertion]

        @inlinable public
        init(selected:Int,
            modified:Int,
            upserted:[Upsertion] = [])
        {
            self.selected = selected
            self.modified = modified
            self.upserted = upserted
        }
    }
}
