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

            while true
            {
                self.beat()
                try await Task.sleep(for: interval)
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
    func stop()
    {
        self.continuation.finish()
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
    init(interval:Duration)
    {
        var heart:Heart? = nil
        self.stream = .init(bufferingPolicy: .bufferingOldest(1))
        {
            (continuation:AsyncThrowingStream<Void, any Error>.Continuation) in

            heart = .init(yieldingTo: continuation, every: interval)
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
