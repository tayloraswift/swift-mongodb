@frozen public
struct Milliseconds:RawRepresentable, Hashable, Sendable
{
    public
    let rawValue:Int64

    @inlinable public
    init(rawValue:Int64)
    {
        self.rawValue = rawValue
    }
}
extension Milliseconds:QuantizedDuration
{
    @inlinable public static
    var unit:String { "ms" }

    @inlinable public
    init(truncating duration:Duration)
    {
        self.init(rawValue: duration.components.seconds * 1_000 +
            duration.components.attoseconds / 1_000_000_000_000_000)
    }
}
extension Milliseconds:ExpressibleByIntegerLiteral
{
}
extension Milliseconds:CustomStringConvertible
{
}
