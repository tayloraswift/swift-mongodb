import UnixTime

extension Mongo
{
    public
    protocol ReplicaTimingBaseline
    {
        static
        func - (self:Self, candidate:ReplicaTimings) -> Milliseconds
    }
}
