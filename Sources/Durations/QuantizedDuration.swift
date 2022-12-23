public
protocol QuantizedDuration<RawValue>:DurationProtocol, RawRepresentable, Hashable, Sendable
    where RawValue:BinaryInteger
{
    init(rawValue:RawValue)
    /// Rounds the given attosecond-resolution duration towards zero.
    init(truncating duration:Duration)
}
extension QuantizedDuration where Self == Minutes
{
    @inlinable public static
    func minutes(_ minutes:Int64) -> Self
    {
        .init(rawValue: minutes)
    }
}
extension QuantizedDuration where Self == Seconds
{
    @inlinable public static
    func seconds(_ seconds:Int64) -> Self
    {
        .init(rawValue: seconds)
    }
    @inlinable public static
    func minutes(_ minutes:Minutes) -> Self
    {
        .init(rawValue: minutes.rawValue * 60)
    }
}
extension QuantizedDuration where Self == Milliseconds
{
    @inlinable public static
    func milliseconds(_ milliseconds:Int64) -> Self
    {
        .init(rawValue: milliseconds)
    }
    @inlinable public static
    func seconds(_ seconds:Seconds) -> Self
    {
        .init(rawValue: seconds.rawValue * 1_000)
    }
    @inlinable public static
    func minutes(_ minutes:Minutes) -> Self
    {
        .init(rawValue: minutes.rawValue * 60_000)
    }
}
extension QuantizedDuration
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension QuantizedDuration
{
    @inlinable public static
    var zero:Self
    {
        .init(rawValue: 0)
    }

    @inlinable public static
    func + (lhs:Self, rhs:Self) -> Self
    {
        .init(rawValue: lhs.rawValue + rhs.rawValue)
    }
    @inlinable public static
    func - (lhs:Self, rhs:Self) -> Self
    {
        .init(rawValue: lhs.rawValue - rhs.rawValue)
    }
}
extension QuantizedDuration
{
    @inlinable public static
    func / (lhs:Self, rhs:Int) -> Self
    {
        .init(rawValue: lhs.rawValue / RawValue.init(rhs))
    }

    @inlinable public static
    func * (lhs:Self, rhs:Int) -> Self
    {
        .init(rawValue: lhs.rawValue * RawValue.init(rhs))
    }

    @inlinable public static
    func / (lhs:Self, rhs:Self) -> Double
    {
        Double.init(lhs.rawValue) / Double.init(rhs.rawValue)
    }
}
