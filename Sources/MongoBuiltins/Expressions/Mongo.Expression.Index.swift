extension Mongo.Expression
{
    @frozen public
    enum Index:String, Hashable, Sendable
    {
        case elementIndex       = "indexOfArray"
        case unicodeScalarIndex = "indexOfCP"
        case utf8Index          = "indexOfBytes"
    }
}
extension Mongo.Expression.Index
{
    @available(*, unavailable, renamed: "elementIndex")
    public static
    var indexOfArray:Self
    {
        .elementIndex
    }
    @available(*, unavailable, renamed: "unicodeScalarIndex")
    public static
    var indexOfCP:Self
    {
        .unicodeScalarIndex
    }
    @available(*, unavailable, renamed: "utf8Index")
    public static
    var indexOfBytes:Self
    {
        .utf8Index
    }
}
