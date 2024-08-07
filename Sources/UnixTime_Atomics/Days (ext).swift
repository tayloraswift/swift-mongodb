import Atomics
import UnixTime

#if swift(>=6.0)
extension Days:@retroactive AtomicValue
{
}
#else
extension Days:AtomicValue
{
}
#endif
