extension BSON.List:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(list: self)
    }
}
extension BSON.List
{
    /// Creates an empty list, and initializes it with the given closure.
    @inlinable public
    init(with encode:(inout BSON.ListEncoder) throws -> ()) rethrows
    {
        self.init()
        try encode(&self.output[as: BSON.ListEncoder.self])
    }

    @inlinable public
    init<Encodable>(elements:some Sequence<Encodable>) where Encodable:BSONEncodable
    {
        self.init
        {
            for element:Encodable in elements
            {
                $0.append(element)
            }
        }
    }
}
