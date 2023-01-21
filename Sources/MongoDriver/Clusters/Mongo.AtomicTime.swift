import Atomics

extension Mongo
{
    final
    class AtomicTime:Sendable, AtomicReference
    {
        let value:ClusterTime

        init(_ value:ClusterTime)
        {
            self.value = value
        }
    }
}
