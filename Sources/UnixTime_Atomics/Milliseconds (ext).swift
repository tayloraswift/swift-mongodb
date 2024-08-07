import Atomics
import UnixTime

#if swift(>=6.0)
extension Milliseconds:@retroactive AtomicValue
{
}
#else
extension Milliseconds:AtomicValue
{
}
#endif
