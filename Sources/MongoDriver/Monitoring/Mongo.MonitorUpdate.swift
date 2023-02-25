import Durations

extension Mongo
{
    enum MonitorUpdate
    {
        case topology(Result<TopologyMonitor.Update, any Error>)
    }
}
