import Atomics

extension Mongo
{
    enum DeploymentState:Sendable
    {
        case unknown
        case capable(DeploymentCapabilities)
    }
}
extension Mongo.DeploymentState
{
    var capabilities:Mongo.DeploymentCapabilities?
    {
        switch self
        {
        case .unknown:                      nil
        case .capable(let capabilities):    capabilities
        }
    }
}
extension Mongo.DeploymentState:AtomicValue
{
}
extension Mongo.DeploymentState:RawRepresentable
{
    init(rawValue:UInt64)
    {
        if  let capabilities:Mongo.DeploymentCapabilities = .init(bitPattern: rawValue)
        {
            self = .capable(capabilities)
        }
        else
        {
            self = .unknown
        }
    }

    var rawValue:UInt64
    {
        self.capabilities?.bitPattern ?? 0
    }
}
