extension Mongo.UpdateDocument
{
    @frozen public
    enum Reduction:String, Hashable, Sendable
    {
        case addToSet = "$addToSet"
        case max = "$max"
        case min = "$min"
        //  $pullAll is a reduction, it only accepts field values that form
        //  BSON lists, but we can’t represent that in our type system.
        case pullAll = "$pullAll"
        case set = "$set"
        case setOnInsert = "$setOnInsert"
    }
}
