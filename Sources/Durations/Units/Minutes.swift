@frozen public
struct Minutes:RawRepresentable, Hashable, Sendable
{
    public
    let rawValue:Int64

    @inlinable public
    init(rawValue:Int64)
    {
        self.rawValue = rawValue
    }
}
extension Minutes:QuantizedDuration
{
    @inlinable public static
    var unit:String { "m" }

    @inlinable public
    init(truncating duration:Duration)
    {
        self.init(rawValue: duration.components.seconds / 60)
    }
}
extension Minutes:ExpressibleByIntegerLiteral
{
}
extension Minutes
{
    @inlinable public
    var seconds:Seconds
    {
        .init(rawValue: 60 * self.rawValue)
    }
    @inlinable public
    var milliseconds:Milliseconds
    {
        .init(rawValue: 60_000 * self.rawValue)
    }
}
