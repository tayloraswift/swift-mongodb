import Atomics

extension Mongo
{
    final
    class AtomicTime:Sendable, AtomicReference
    {
        let notarized:NotarizedTime

        init(_ notarized:NotarizedTime)
        {
            self.notarized = notarized
        }
    }
}
extension Mongo.AtomicTime
{
    convenience
    init?(_ time:Mongo.ClusterTime)
    {
        if let max:Mongo.NotarizedTime = time.max
        {
            self.init(max)
        }
        else
        {
            return nil
        }
    }
}
