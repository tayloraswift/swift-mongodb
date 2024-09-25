import Atomics
import UnixTime

#if compiler(>=6.0)
extension Seconds:@retroactive AtomicValue
{
}
#else
extension Seconds:AtomicValue
{
}
#endif
