import BSON
import Durations

extension BSON.Millisecond:InstantProtocol
{
    @inlinable public
    func advanced(by duration:Milliseconds) -> Self
    {
        .init(self.value + duration.rawValue)
    }
    @inlinable public
    func duration(to other:Self) -> Milliseconds
    {
        .init(rawValue: other.value - self.value)
    }
}
