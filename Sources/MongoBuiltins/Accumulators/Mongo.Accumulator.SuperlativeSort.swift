extension Mongo.Accumulator
{
    @frozen public
    enum SuperlativeSort:String, Hashable, Sendable
    {
        case bottom = "$bottom"
        case top    = "$top"
    }
}
extension Mongo.Accumulator.SuperlativeSort
{
    @inlinable public
    var n:String
    {
        switch self
        {
        case .bottom:   "$bottomN"
        case .top:      "$topN"
        }
    }
}
extension Mongo.Accumulator.SuperlativeSort
{
    @available(*, unavailable, renamed: "top")
    public static
    var topN:Self
    {
        .top
    }
    @available(*, unavailable, renamed: "bottom")
    public static
    var bottomN:Self
    {
        .bottom
    }
}
