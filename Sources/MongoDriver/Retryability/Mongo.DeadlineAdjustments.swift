extension Mongo
{
    @frozen @usableFromInline
    struct DeadlineAdjustments:Sendable
    {
        /// A **logical deadline** is the deadline the driver communicates to the server. It is
        /// computed as the nominal (user-supplied) timeout minus the network latency metric.
        @usableFromInline
        let logical:ContinuousClock.Instant
        /// A **network deadline** is the deadline the driver uses to time out network requests.
        /// It is computed as the ``logical`` deadline plus whatever global network timeout the
        /// driver is using. Having a separate network deadline makes it far less likely that
        /// natural variations in network latency will disrupt things such as tailable cursors.
        @usableFromInline
        let network:ContinuousClock.Instant

        init(logical:ContinuousClock.Instant, network:ContinuousClock.Instant)
        {
            self.logical = logical
            self.network = network
        }
    }
}
