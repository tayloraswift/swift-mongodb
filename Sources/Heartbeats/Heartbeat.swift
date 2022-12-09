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
        every interval:Duration,
        skip:Int)
    {
        self.init(continuation)
        let beats:Task<Void, any Error> = .init
        {
            [self] in

            let clock:ContinuousClock = .init()
            var next:ContinuousClock.Instant = clock.now
            
            if  skip > 0
            {
                next = next.advanced(by: interval * skip)
                try await Task.sleep(until: next, clock: clock)
            }
            while true
            {
                next = next.advanced(by: interval)
                
                self.beat()
                try await Task.sleep(until: next, clock: clock)
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

@frozen public
struct Heartbeat
{
    private
    let stream:AsyncThrowingStream<Void, any Error>
    public
    let heart:Heart

    public
    init(interval:Duration, skip:Int = 0)
    {
        var heart:Heart? = nil
        self.stream = .init(bufferingPolicy: .bufferingOldest(1))
        {
            (continuation:AsyncThrowingStream<Void, any Error>.Continuation) in

            heart = .init(yieldingTo: continuation, every: interval, skip: skip)
        }
        self.heart = heart!
    }
}
extension Heartbeat:AsyncSequence
{
    public
    typealias Element = Void

    public
    func makeAsyncIterator() -> AsyncThrowingStream<Void, any Error>.Iterator
    {
        self.stream.makeAsyncIterator()
    }
}
