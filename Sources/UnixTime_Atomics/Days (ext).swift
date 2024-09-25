import Atomics
import UnixTime

#if compiler(>=6.0)
extension Days:@retroactive AtomicValue
{
}
#else
extension Days:AtomicValue
{
}
#endif
