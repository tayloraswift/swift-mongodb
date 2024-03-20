import Durations

extension Mongo
{
    public
    protocol ReplicaTimingBaseline
    {
        static
        func - (self:Self, candidate:ReplicaTimings) -> Milliseconds
    }
}
