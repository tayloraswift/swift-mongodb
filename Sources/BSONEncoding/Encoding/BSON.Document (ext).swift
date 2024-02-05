extension BSON.Document:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(document: BSON.DocumentView.init(self))
    }
}
extension BSON.Document
{
    @inlinable public
    subscript<CodingKey>(_:CodingKey.Type) -> BSON.DocumentEncoder<CodingKey>
    {
        _read   { yield  self.output[as: BSON.DocumentEncoder<CodingKey>.self] }
        _modify { yield &self.output[as: BSON.DocumentEncoder<CodingKey>.self] }
    }
}
extension BSON.Document
{
    @inlinable public
    subscript(with key:some RawRepresentable<String>) -> BSON.FieldEncoder
    {
        _read   { yield  self.output[with: .init(key)] }
        _modify { yield &self.output[with: .init(key)] }
    }
}
