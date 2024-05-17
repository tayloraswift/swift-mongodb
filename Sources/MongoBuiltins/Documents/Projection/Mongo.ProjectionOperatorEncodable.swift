extension Mongo
{
    public
    protocol ProjectionOperatorEncodable
    {
        func encode(to operator:inout ProjectionOperatorEncoder)
    }
}
