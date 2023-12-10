extension Mongo
{
    @frozen public
    struct NetworkError:Error
    {
        public
        let underlying:any Error
        public
        let provenance:NetworkErrorProvenance?

        @inlinable public
        init(underlying:any Error, provenance:NetworkErrorProvenance? = nil)
        {
            self.underlying = underlying
            self.provenance = provenance
        }
    }
}
