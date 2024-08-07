import Atomics
import UnixTime

#if swift(>=6.0)
extension Minutes:@retroactive AtomicValue
{
}
#else
extension Minutes:AtomicValue
{
}
#endif
