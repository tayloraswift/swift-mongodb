@frozen public
struct Microseconds:RawRepresentable, Hashable, Sendable
{
    public
    let rawValue:Int64

    @inlinable public
    init(rawValue:Int64)
    {
        self.rawValue = rawValue
    }
}
extension Microseconds:QuantizedDuration
{
    @inlinable public
    init(truncating duration:Duration)
    {
        self.init(rawValue: duration.components.seconds * 1_000_000 +
            duration.components.attoseconds / 1_000_000_000_000)
    }
}
extension Microseconds:ExpressibleByIntegerLiteral
{
}
