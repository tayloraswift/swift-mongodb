import Durations

extension Mongo
{
    public
    enum SamplerEvent:Sendable
    {
        case sampled(Duration, metric:Nanoseconds)
        case errored(any Error)
    }
}
