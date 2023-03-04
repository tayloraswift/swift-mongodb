import Atomics

extension Mongo.DeploymentCapabilities
{
    struct BitPattern:RawRepresentable, AtomicValue
    {
        let rawValue:UInt64

        init(rawValue:UInt64)
        {
            self.rawValue = rawValue
        }
    }
}
extension Mongo.DeploymentCapabilities.BitPattern
{
    init(_ capablities:Mongo.DeploymentCapabilities?)
    {
        guard let capablities:Mongo.DeploymentCapabilities
        else
        {
            self.init(rawValue: 0)
            return
        }
        switch capablities.transactions
        {
        case .supported?:
            self.init(rawValue: UInt64.init(capablities.sessions.rawValue) << 32 | 0x0000_0002)
        
        case nil:
            self.init(rawValue: UInt64.init(capablities.sessions.rawValue) << 32 | 0x0000_0001)
        }
    }
}
