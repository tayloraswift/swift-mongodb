import Durations
import MongoLogging

extension Mongo.Sampler
{
    /// A sampler event is a measurement of the roundtrip ping to a server.
    @frozen public
    enum Event:Sendable
    {
        /// A ping succeeded. The duration is the roundtrip duration and the `metric` is a
        /// smoothed statistic of the roundtrip duration.
        case sampled(Duration, metric:Nanoseconds)
        /// A ping errored.
        case errored(any Error)
    }
}
extension Mongo.Sampler.Event:Mongo.MonitorEventType
{
    @inlinable public static
    var component:Mongo.MonitorService { .sampler }

    @inlinable public
    var severity:Mongo.LogSeverity
    {
        switch self
        {
        case .sampled:  .debug
        case .errored:  .error
        }
    }
}
extension Mongo.Sampler.Event:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .sampled(let sample, metric: let metric):  "sampled (\(sample), metric: \(metric))"
        case .errored(let error):                       "errored (\(error))"
        }
    }
}
