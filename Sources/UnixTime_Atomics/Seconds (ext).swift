import Atomics
import UnixTime

#if swift(>=6.0)
extension Seconds:@retroactive AtomicValue
{
}
#else
extension Seconds:AtomicValue
{
}
#endif
