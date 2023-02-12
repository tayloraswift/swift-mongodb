extension Mongo.Accumulator
{
    @frozen public
    enum Superlative:String, Hashable, Sendable
    {
        case first  = "$first"
        case last   = "$last"
        case max    = "$max"
        case min    = "$min"
    }
}
extension Mongo.Accumulator.Superlative
{
    @inlinable public
    var n:String
    {
        switch self
        {
        case .first:    return "$firstN"
        case .last:     return "$lastN"
        case .max:      return "$maxN"
        case .min:      return "$minN"
        }
    }
}
extension Mongo.Accumulator.Superlative
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
