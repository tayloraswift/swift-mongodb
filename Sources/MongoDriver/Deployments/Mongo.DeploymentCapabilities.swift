extension Mongo
{
    struct DeploymentCapabilities:Sendable
    {
        let transactions:Bool
        let sessions:Sessions
    }
}
extension Mongo.DeploymentCapabilities
{
    init?(bitPattern:UInt64)
    {
        let sessions:Sessions = .init(rawValue: .init(bitPattern >> 32))

        switch bitPattern & 0xffff_ffff
        {
        case 0x0000_0001:
            self.init(transactions: false, sessions: sessions)

        case 0x0000_0002:
            self.init(transactions: true, sessions: sessions)

        default:
            return nil
        }
    }

    var bitPattern:UInt64
    {
        .init(self.sessions.rawValue) << 32 | (self.transactions ? 0x0000_0002 : 0x0000_0001)
    }
}
