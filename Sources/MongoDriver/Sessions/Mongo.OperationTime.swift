extension Mongo
{
    @frozen public
    struct OperationTime:Sendable
    {
        public
        let max:Instant?

        @inlinable public
        init(_ time:Instant?)
        {
            self.max = time
        }
    }
}
extension Mongo.OperationTime
{
    @inlinable public
    func combined(with time:Mongo.Instant) -> Self
    {
        guard let max:Mongo.Instant = self.max
        else
        {
            return .init(time)
        }
        if  max < time
        {
            return .init(time)
        }
        else
        {
            return self
        }
    }
    @inlinable public mutating
    func combine(with time:Mongo.Instant)
    {
        self = self.combined(with: time)
    }
}
