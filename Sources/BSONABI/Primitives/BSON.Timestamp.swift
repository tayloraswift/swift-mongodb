extension BSON
{
    @frozen public
    struct Timestamp:Equatable, Hashable, Sendable
    {
        public
        var value:UInt64

        @inlinable public
        init(_ value:UInt64)
        {
            self.value = value
        }
    }
}
extension BSON.Timestamp
{
    @inlinable public static
    var max:Self { .init(.max) }

    @inlinable public static
    var min:Self { .init(.min) }
}
extension BSON.Timestamp:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.value < b.value }
}
extension BSON.Timestamp:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:UInt64) { self.init(integerLiteral) }
}
extension BSON.Timestamp:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.value >> 32)+\(self.value & 0x0000_0000_ffff_ffff)"
    }
}
