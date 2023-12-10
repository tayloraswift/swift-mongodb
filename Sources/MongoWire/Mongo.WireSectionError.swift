extension Mongo
{
    /// The subtype byte of a binary array was matched a reserved bit pattern.
    @frozen public
    struct WireSectionError:Equatable, Error
    {
        public
        let code:UInt8

        @inlinable public
        init(invalid code:UInt8)
        {
            self.code = code
        }
    }
}
extension Mongo.WireSectionError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid MongoDB message section type code (\(self.code))"
    }
}
