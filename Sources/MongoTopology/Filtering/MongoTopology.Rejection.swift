//import MongoConnection

extension MongoTopology
{
    public
    struct Rejection<Reason>
    {
        public
        let reason:Reason
        public
        let host:MongoTopology.Host

        public
        init(reason:Reason, host:MongoTopology.Host)
        {
            self.reason = reason
            self.host = host
        }
    }
}
extension MongoTopology.Rejection:Equatable where Reason:Equatable
{
}
extension MongoTopology.Rejection:Sendable where Reason:Sendable
{
}
// extension MongoTopology.Rejection<MongoTopology.Unreachable>
// {
//     init(host:MongoTopology.Host, state:MongoConnection<Never>.State)
//     {
//         switch state
//         {
//         }
//     }
// }

