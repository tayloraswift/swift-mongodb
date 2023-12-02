import BSON
import Durations

extension Mongo
{
    /// A variant of the MongoDB `hello` command, also known as `isMaster`,
    /// the driver sends after completing an initial ``Hello``, for
    /// topology monitoring purposes.
    struct AwaitableHello:Sendable
    {
        let topologyVersion:TopologyVersion
        let milliseconds:Milliseconds

        init(topologyVersion:TopologyVersion, milliseconds:Milliseconds)
        {
            self.topologyVersion = topologyVersion
            self.milliseconds = milliseconds
        }
    }
}
extension Mongo.AwaitableHello
{
    /// The string [`"hello"`]().
    static
    var type:Mongo.CommandType { .hello }
}
extension Mongo.AwaitableHello:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson[.init(Self.type)] = true
        bson["topologyVersion"] = self.topologyVersion
        bson["maxAwaitTimeMS"] = self.milliseconds
    }
}
