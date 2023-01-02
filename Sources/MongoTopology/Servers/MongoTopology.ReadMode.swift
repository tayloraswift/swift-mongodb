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
    public
    func diagnose(undesirable members:MongoTopology.Members)
        -> [MongoTopology.Host: MongoTopology.Undesirable]
    {
        switch self
        {
        case .primary:
            return members.candidates.secondaries.reduce(into: members.undesirables)
            {
                $0[$1.host] = .secondary
            }
        
        case .primaryPreferred, .nearest, .secondaryPreferred:
            return members.undesirables
        
        case .secondary:
            var undesirables:[MongoTopology.Host: MongoTopology.Undesirable] =
                members.undesirables
            if  let primary:MongoTopology.Host =
                    members.candidates.primary?.host
            {
                undesirables[primary] = .primary
            }
            return undesirables
        }
    }
}
