import Atomics
import UnixTime

#if compiler(>=6.0)
extension Minutes:@retroactive AtomicValue
{
}
#else
extension Minutes:AtomicValue
{
}
#endif
