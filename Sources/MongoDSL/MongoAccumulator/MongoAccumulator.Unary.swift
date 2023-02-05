extension MongoAccumulator
{
    @frozen public
    enum Unary:String, Hashable, Sendable
    {
        case addToSet           = "$addToSet"
        case avg                = "$avg"
        case mergeObjects       = "$mergeObjects"
        case push               = "$push"
        case stdDevPopulation   = "$stdDevPop"
        case stdDevSample       = "$stdDevSamp"
        case sum                = "$sum"
    }
}
