extension BSON.ShapeError
{
    /// What shape you expected a list or binary array to have.
    @frozen public
    enum Criteria:Hashable, Sendable
    {
        case length(Int)
        case multiple(of:Int)
    }
}
