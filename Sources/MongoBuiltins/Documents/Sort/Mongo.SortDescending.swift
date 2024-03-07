extension Mongo
{
    @frozen public
    enum SortDescending
    {
    }
}
extension Mongo.SortDescending:Mongo.SortDirection
{
    @inlinable public static
    var code:Int32 { -1 }
}
extension Mongo.SortDescending
{
    @inlinable public static prefix
    func - (lhs:Self) -> Never
    {
    }
}
