import MongoChannel

extension MongoChannel.State<MongoTopology.Replica?>
{
    /// Returns the stored channel, if this descriptor currently has one,
    /// and its metadata indicates it is a primary replica.
    var primary:MongoChannel?
    {
        if case .connected(let channel, metadata: .primary(_)?) = self
        {
            return channel
        }
        else
        {
            return nil
        }
    }
}
