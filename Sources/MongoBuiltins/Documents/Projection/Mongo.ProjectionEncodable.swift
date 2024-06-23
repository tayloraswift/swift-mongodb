extension Mongo
{
    public
    protocol ProjectionEncodable<CodingKey>
    {
        associatedtype CodingKey:RawRepresentable<String>

        func encode(to projection:inout ProjectionEncoder<CodingKey>)
    }
}
