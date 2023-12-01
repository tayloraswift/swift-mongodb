import BSONTypes

extension BSON.InputError
{
    @frozen public
    enum Expectation:Equatable, Sendable
    {
        /// The input should have yielded end-of-input.
        case end
        /// The input should have yielded a terminator byte that never appeared.
        case byte(UInt8)
        /// The input should have yielded a particular number of bytes.
        case bytes(Int)
    }
}
extension BSON.InputError.Expectation:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .end:
            "end-of-input"
        case .byte(let byte):
            "terminator byte (\(byte))"
        case .bytes(let count):
            "\(count) byte(s)"
        }
    }
}
