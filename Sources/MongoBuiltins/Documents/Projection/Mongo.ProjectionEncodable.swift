extension Mongo
{
    public
    protocol ProjectionEncodable
    {
        func encode(to projection:inout ProjectionEncoder)
    }
}
