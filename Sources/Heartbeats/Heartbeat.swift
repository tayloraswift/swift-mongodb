@frozen public
struct Heartbeat
{
    private
    let stream:AsyncThrowingStream<Void, any Error>
    public
    let heart:Heart

    /// Creates a heartbeat that will yield on multiples of the given interval.
    /// The first heartbeat will not appear until exactly one interval has
    /// elapsed.
    ///
    /// The automatic heartbeat will not drift over time, and will always
    /// yield on multiples of `interval`, which is useful for staggering
    /// multiple heartbeats.
    ///
    /// A maximum of one heartbeat will be buffered. If additional heartbeats are
    /// missed because the consumer was suspended, only one heartbeat will be
    /// yielded when the consumer resumes iteration.
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
