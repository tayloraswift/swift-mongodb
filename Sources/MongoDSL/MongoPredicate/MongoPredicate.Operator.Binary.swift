extension MongoPredicate.Operator
{
    @frozen public
    enum Binary:String, Hashable, Sendable
    {
        case bitsAllClear   = "$bitsAllClear"
        case bitsAllSet     = "$bitsAllSet"
        case bitsAnyClear   = "$bitsAnyClear"
        case bitsAnySet     = "$bitsAnySet"

        case eq             = "$eq"
        case gt             = "$gt"
        case gte            = "$gte"
        case lt             = "$lt"
        case lte            = "$lte"
        case neq            = "$neq"
        
        case size           = "$size"
    }
}
