extension MongoAccumulator
{
    @frozen public
    enum SuperlativeSort:String, Hashable, Sendable
    {
        case bottom = "$bottom"
        case top    = "$top"
    }
}
extension MongoAccumulator.SuperlativeSort
{
    @inlinable public
    var n:String
    {
        switch self
        {
        case .bottom:   return "$bottomN"
        case .top:      return "$topN"
        }
    }
}
extension MongoAccumulator.SuperlativeSort
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
