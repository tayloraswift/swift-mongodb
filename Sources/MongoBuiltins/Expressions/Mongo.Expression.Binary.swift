extension Mongo.Expression
{
    @frozen public
    enum Binary:String, Hashable, Sendable
    {
        case cmp    = "$cmp"
        case eq     = "$eq"
        case gt     = "$gt"
        case gte    = "$gte"
        case lt     = "$lt"
        case lte    = "$lte"
        case ne     = "$ne"

        case setDifference = "$setDifference"
        case setIsSubset = "$setIsSubset"
    }
}
