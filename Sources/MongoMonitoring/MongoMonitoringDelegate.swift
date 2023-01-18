/// A type that can initiate and halt server monitoring on behalf
/// of a topology model.
public
protocol MongoMonitoringDelegate
{
    /// Requests an immediate recheck of the relevant server.
    func requestRecheck()
    /// Stops monitoring the relevant server.
    func stopMonitoring()
    /// Stops monitoring the relevant server, reporting the given error.
    func stopMonitoring(throwing error:any Error)
}
