extension Mongo
{
    struct Latency:Sendable
    {
        let duration:Duration

        init(_ duration:Duration)
        {
            self.duration = duration
        }
    }
}
extension Mongo.Latency
{
    var nanoseconds:Double
    {
        1e-9 * Double.init(self.duration.components.attoseconds) +
        1e+9 * Double.init(self.duration.components.seconds)
    }
}
