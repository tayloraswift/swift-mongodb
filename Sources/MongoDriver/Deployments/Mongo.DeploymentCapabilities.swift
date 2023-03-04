extension Mongo
{
    @frozen public
    struct DeploymentCapabilities:Sendable
    {
        public
        let transactions:Transactions?
        public
        let sessions:Sessions

        init(transactions:Transactions?, sessions:Sessions)
        {
            self.transactions = transactions
            self.sessions = sessions
        }
    }
}
extension Mongo.DeploymentCapabilities
{
    init?(bitPattern:BitPattern)
    {
        let transactions:Transactions?
        switch bitPattern.rawValue & 0xffff_ffff
        {
        case 0x0000_0002:
            transactions = .supported
        case 0x0000_0001:
            transactions = nil
        default:
            return nil
        }
        let sessions:Sessions = .init(rawValue: .init(bitPattern.rawValue >> 32))
        self.init(transactions: transactions, sessions: sessions)
    }
}
