extension MongoSortOrdering
{
    public
    enum Ascending
    {
    }
}
extension MongoSortOrdering.Ascending
{
    public static prefix
    func + (lhs:Self) -> Never
    {
    }
}
