extension Mongo
{
    @frozen public
    struct ClusterTime:Sendable
    {
        public
        let max:NotarizedTime?

        init(_ notarized:NotarizedTime?)
        {
            self.max = notarized
        }
    }
}
extension Mongo.ClusterTime
{
    func combined(with notarized:Mongo.NotarizedTime) -> Self
    {
        guard let max:Mongo.NotarizedTime = self.max
        else
        {
            return .init(notarized)
        }
        if  max.time < notarized.time
        {
            return .init(notarized)
        }
        else
        {
            return self
        }
    }
    mutating
    func combine(with notarized:Mongo.NotarizedTime)
    {
        self = self.combined(with: notarized)
    }
}
