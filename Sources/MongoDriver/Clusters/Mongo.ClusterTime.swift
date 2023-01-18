extension Mongo
{
    @frozen public
    struct ClusterTime:Sendable
    {
        public
        let max:Sample?

        init(_ sample:Sample?)
        {
            self.max = sample
        }
    }
}
extension Mongo.ClusterTime
{
    func combined(with sample:Sample) -> Self
    {
        guard let max:Sample = self.max
        else
        {
            return .init(sample)
        }
        if  max < sample
        {
            return .init(sample)
        }
        else
        {
            return self
        }
    }
    mutating
    func combine(with sample:Sample)
    {
        self = self.combined(with: sample)
    }
}
