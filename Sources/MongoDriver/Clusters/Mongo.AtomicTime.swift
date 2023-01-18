import Atomics

extension Mongo
{
    final
    class AtomicTime:Sendable, AtomicReference
    {
        let value:Mongo.ClusterTime.Sample

        init(_ value:Mongo.ClusterTime.Sample)
        {
            self.value = value
        }
    }
}
extension Mongo.AtomicTime
{
    convenience
    init?(_ time:Mongo.ClusterTime)
    {
        if let max:Mongo.ClusterTime.Sample = time.max
        {
            self.init(max)
        }
        else
        {
            return nil
        }
    }
}
