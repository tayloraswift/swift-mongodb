extension Mongo
{
    @frozen public
    struct ClusterTime:Sendable
    {
        public private(set)
        var max:Sample?

        init(_ sample:Sample?)
        {
            self.max = sample
        }
    }
}
extension Mongo.ClusterTime
{
    mutating
    func combine(with sample:Sample)
    {
        guard let max:Sample = self.max
        else
        {
            self.max = sample
            return
        }
        if  max.instant < sample.instant
        {
            self.max = sample
        }
    }
}
