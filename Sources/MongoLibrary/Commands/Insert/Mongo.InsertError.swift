extension Mongo
{
    @frozen public
    struct InsertError:Error, Equatable, Sendable
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
