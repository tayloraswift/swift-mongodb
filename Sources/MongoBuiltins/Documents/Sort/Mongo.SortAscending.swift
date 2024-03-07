extension Mongo
{
    @frozen public
    enum SortAscending
    {
    }
}
extension Mongo.SortAscending:Mongo.SortDirection
{
    @inlinable public static
    var code:Int32 { 1 }
}
extension Mongo.SortAscending
{
    @inlinable public static prefix
    func + (lhs:Self) -> Never
    {
    }
}
