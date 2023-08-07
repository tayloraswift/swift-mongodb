extension Mongo.Expression
{
    @frozen public
    enum Unary:String, Hashable, Sendable
    {
        case abs            = "$abs"
        case arrayToObject  = "$arrayToObject"
        case binarySize     = "$binarySize"
        case objectSize     = "$bsonSize"
        case objectToArray  = "$objectToArray"
        case ceil           = "$ceil"
        case exp            = "$exp"
        case first          = "$first"
        case floor          = "$floor"
        case last           = "$last"
        case literal        = "$literal"
        case ln             = "$ln"
        case log10          = "$log10"
        case reverseArray   = "$reverseArray"
        case size           = "$size"
        case sqrt           = "$sqrt"
    }
}
