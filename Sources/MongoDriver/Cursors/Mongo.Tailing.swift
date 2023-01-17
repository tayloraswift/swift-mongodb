import Durations

extension Mongo
{
    @frozen public
    struct Tailing:Hashable, Sendable
    {
        public
        let timeout:OperationTimeout?
        public
        let awaits:Bool

        @inlinable public
        init(timeout:OperationTimeout?, awaits:Bool)
        {
            self.timeout = timeout
            self.awaits = awaits
        }
    }
}
