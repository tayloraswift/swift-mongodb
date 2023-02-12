@frozen public
struct Nanoseconds:RawRepresentable, Hashable, Sendable
{
    public
    let rawValue:Int64

    @inlinable public
    init(rawValue:Int64)
    {
        self.rawValue = rawValue
    }
}
extension Nanoseconds:QuantizedDuration
{
    @inlinable public
    init(truncating duration:Duration)
    {
        self.init(rawValue: duration.components.seconds * 1_000_000_000 +
            duration.components.attoseconds / 1_000_000_000)
    }
}
extension Nanoseconds:ExpressibleByIntegerLiteral
{
}
