extension Mongo.UpdateDocument
{
    /// Takes a document and removes the specified fields.
    /// Not to be confused with the ``Mongo.PipelineState.Unset unset``
    /// aggregation pipeline stage, which can take a field path directly.
    @frozen public
    enum Unset:String, Hashable, Sendable
    {
        case unset = "$unset"
    }
}
