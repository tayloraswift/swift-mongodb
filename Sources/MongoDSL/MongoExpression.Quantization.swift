extension MongoExpression
{
    @frozen public
    enum Quantization:String, Hashable, Sendable
    {
        case round = "$round"
        case trunc = "$trunc"
    }
}
