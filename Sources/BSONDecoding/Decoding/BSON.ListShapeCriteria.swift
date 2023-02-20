extension BSON
{
    /// What shape you expected an array to have.
    @frozen public
    enum ListShapeCriteria:Hashable, Sendable
    {
        case count(Int)
        case multiple(of:Int)
    }
}
