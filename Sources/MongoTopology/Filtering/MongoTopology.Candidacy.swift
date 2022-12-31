import BSONSchema

extension MongoTopology
{
    @frozen public
    enum Candidacy:String, Hashable, Sendable
    {
        case primaryRequired = "primary"
        case primaryPreferred
        case secondaryPreferred
        case secondaryRequired = "secondary"
        case nearest
    }
}
extension MongoTopology.Candidacy:BSONScheme
{
}
