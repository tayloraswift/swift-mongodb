extension MongoSortOrdering
{
    public
    enum Descending
    {
    }
}
extension MongoSortOrdering.Descending
{
    public static prefix
    func - (lhs:Self) -> Never
    {
    }
}
