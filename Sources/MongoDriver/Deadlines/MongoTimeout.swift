import Durations

public
protocol MongoTimeout<Deadline>:QuantizedDuration
{
    associatedtype Deadline:InstantProtocol<Duration>

    init(milliseconds:Milliseconds)
    var milliseconds:Milliseconds { get }
}
extension MongoTimeout where Self:RawRepresentable
{
    @inlinable public static
    var unit:String
    {
        Milliseconds.unit
    }
    
    @inlinable public
    var rawValue:Milliseconds.RawValue
    {
        self.milliseconds.rawValue
    }
    @inlinable public
    init(rawValue:Milliseconds.RawValue)
    {
        self.init(milliseconds: .init(rawValue: rawValue))
    }
}
extension MongoTimeout where Self:QuantizedDuration
{
    @inlinable public
    init(truncating duration:Duration)
    {
        self.init(milliseconds: .init(truncating: duration))
    }
}
extension MongoTimeout
{
    @inlinable public
    func deadline(from start:Deadline) -> Deadline
    {
        start.advanced(by: .milliseconds(self.milliseconds))
    }
}
extension MongoTimeout<ContinuousClock.Instant>
{
    @inlinable public
    func deadline() -> Deadline
    {
        self.deadline(from: .now)
    }
}
