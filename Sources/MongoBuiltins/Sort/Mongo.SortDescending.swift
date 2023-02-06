extension Mongo
{
    public
    enum SortDescending
    {
    }
}
extension Mongo.SortDescending
{
    public static prefix
    func - (lhs:Self) -> Never
    {
    }
}
