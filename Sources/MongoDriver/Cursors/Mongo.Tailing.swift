import Durations

extension Mongo
{
    @frozen public
    struct Tailing:Hashable, Sendable
    {
        public
        let timeout:Milliseconds?
        public
        let awaits:Bool

        @inlinable public
        init(timeout:Milliseconds?, awaits:Bool)
        {
            self.timeout = timeout
            self.awaits = awaits
        }
    }
}
