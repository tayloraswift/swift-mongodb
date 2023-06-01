extension BSON.List
{
    /// Creates an empty list, and initializes it with the given closure.
    @inlinable public
    init(with populate:(inout BSON.ListEncoder) throws -> ()) rethrows
    {
        self.init()
        try populate(&self.output[as: BSON.ListEncoder.self])
    }

    @inlinable public
    init<Encodable>(elements:some Sequence<Encodable>) where Encodable:BSONWeakEncodable
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
extension BSON.List:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(list: .init(self))
    }
}
