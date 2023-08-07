extension Mongo.Expression
{
    @frozen public
    enum Superlative:String, Hashable, Sendable
    {
        case first  = "$firstN"
        case last   = "$lastN"
        case max    = "$maxN"
        case min    = "$minN"
    }
}
extension Mongo.Expression.Superlative
{
    @available(*, unavailable, renamed: "first")
    public static
    var firstN:Self
    {
        .first
    }
    @available(*, unavailable, renamed: "last")
    public static
    var lastN:Self
    {
        .last
    }
    @available(*, unavailable, renamed: "max")
    public static
    var maxN:Self
    {
        .max
    }
    @available(*, unavailable, renamed: "min")
    public static
    var minN:Self
    {
        .min
    }
}
