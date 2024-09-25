import Atomics
import UnixTime

#if compiler(>=6.0)
extension Milliseconds:@retroactive AtomicValue
{
}
#else
extension Milliseconds:AtomicValue
{
}
#endif
