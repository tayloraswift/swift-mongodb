import BSONSchema

extension MongoTopology
{
    @frozen public
    enum ReadMode:String, Hashable, Sendable
    {
        case primary
        case primaryPreferred
        case secondaryPreferred
        case secondary
        case nearest
    }
}
extension MongoTopology.ReadMode:BSONScheme
{
}
extension MongoTopology.ReadMode
{
    func diagnose(undesirable members:MongoTopology.Members)
        -> [MongoTopology.Rejection<MongoTopology.Undesirable>]
    {
        switch self
        {
        case .primary:
            return members.undesirables + members.candidates.secondaries.lazy.map
            {
                .init(reason: .secondary, host: $0.host)
            }
        
        case .primaryPreferred, .nearest, .secondaryPreferred:
            return members.undesirables
        
        case .secondary:
            return members.candidates.primary.map
            {
                members.undesirables + [.init(reason: .primary, host: $0.host)]
            }
            ??  members.undesirables
        }
    }
}
