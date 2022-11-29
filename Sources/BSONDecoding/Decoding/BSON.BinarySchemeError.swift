extension BSON
{
    /// A binary array had an invalid scheme.
    @frozen public
    enum BinarySchemeError:Equatable, Error
    {
        case subtype(invalid:BSON.BinarySubtype)
        case shape(invalid:Int, expected:Int? = nil)
    }
}
extension BSON.BinarySchemeError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .subtype(invalid: let subtype):
            return "invalid subtype '\(subtype)'"
        case .shape(invalid: let size, expected: nil):
            return "invalid byte count (\(size))"
        case .shape(invalid: let size, expected: let expected?):
            return "invalid byte count (\(size)), expected \(expected) bytes"
        }
    }
}
