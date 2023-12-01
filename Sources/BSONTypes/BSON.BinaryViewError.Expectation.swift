extension BSON.BinaryViewError
{
    @frozen public
    enum Expectation:Equatable, Sendable
    {
        /// The input should have yielded a subtype byte.
        case subtype
        /// The input should have yielded a legacy subheader.
        case subheader
    }
}
extension BSON.BinaryViewError.Expectation:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .subtype:
            "subtype (1 byte)"
        case .subheader:
            "subheader (4 bytes)"
        }
    }
}
