@frozen public
struct Heart:Sendable
{
    let continuation:AsyncThrowingStream<Void, any Error>.Continuation

    init(_ continuation:AsyncThrowingStream<Void, any Error>.Continuation)
    {
        self.continuation = continuation
    }
}
extension Heart
{
    init(yieldingTo continuation:AsyncThrowingStream<Void, any Error>.Continuation,
        every interval:Duration)
    {
        self.init(continuation)
        let beats:Task<Void, any Error> = .init
        {
            [self] in

            let clock:ContinuousClock = .init()
            var next:ContinuousClock.Instant = clock.now
            while true
            {
                next = next.advanced(by: interval)
                try await Task.sleep(until: next, clock: clock)
                self.beat()
            }
        }
        self.continuation.onTermination = 
        {
            _ in
            beats.cancel()
        }
    }
}
extension Heart
{
    public
    func beat()
    {
        self.continuation.yield()
    }
    public
    func stop(throwing error:(any Error)? = nil)
    {
        self.continuation.finish(throwing: error)
    }
}
