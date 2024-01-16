extension BSON
{
    /// A number of UTC milliseconds since the Unix epoch.
    ///
    /// This library does not have access to calender-aware facilities. When using this type’s
    /// ``Equatable``, ``Hashable``, or ``Comparable`` features, keep in mind that a
    /// `Millisecond` is just a number, and is only as meaningful as the clock (if any) that
    /// produced it.
    @frozen public
    struct Millisecond:Hashable, Equatable, Sendable
    {
        public
        let value:Int64

        @inlinable public
        init(_ value:Int64)
        {
            self.value = value
        }
    }
}
extension BSON.Millisecond:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.value < b.value }
}
extension BSON.Millisecond:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:Int64) { self.init(integerLiteral) }
}
