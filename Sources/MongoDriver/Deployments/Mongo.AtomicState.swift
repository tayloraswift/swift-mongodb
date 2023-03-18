import Atomics

extension Mongo
{
    final
    class AtomicState<T>:AtomicReference, Sendable where T:Sendable
    {
        let value:T

        init(_ value:T)
        {
            self.value = value
        }
    }
}
