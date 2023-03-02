import Durations

extension Mongo
{
    @frozen public
    struct ConnectionPoolSettings:Equatable, Sendable
    {
        /// The target size of a connection pool. The pool will attempt to expand
        /// until it contains at least the minimum number of connections, and it will
        /// never exceed the maximum connection count.
        public
        let size:ClosedRange<Int>
        /// The maximum number of connections a pool can establish concurrently.
        public
        let rate:Int

        public
        init(size:ClosedRange<Int> = 0 ... 100,
            rate:Int = 2)
        {
            self.size = size
            self.rate = rate
        }
    }
}
