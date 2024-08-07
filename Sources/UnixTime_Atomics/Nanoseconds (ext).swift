import Atomics
import UnixTime

#if swift(>=6.0)
extension Nanoseconds:@retroactive AtomicValue
{
}
#else
extension Nanoseconds:AtomicValue
{
}
#endif
