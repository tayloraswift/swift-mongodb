@frozen public
struct Seconds:RawRepresentable, Hashable, Sendable
{
    public
    let rawValue:Int64

    @inlinable public
    init(rawValue:Int64)
    {
        self.rawValue = rawValue
    }
}
extension Seconds:QuantizedDuration
{
    @inlinable public static
    var unit:String { "s" }

    @inlinable public
    init(truncating duration:Duration)
    {
        self.init(rawValue: duration.components.seconds)
    }
}
extension Seconds:ExpressibleByIntegerLiteral
{
}
extension Seconds:CustomStringConvertible
{
}
extension Seconds
{
    @inlinable public
    var milliseconds:Milliseconds
    {
        .init(rawValue: 1_000 * self.rawValue)
    }
}
