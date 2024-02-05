extension Dictionary:BSONDecodable where Key == BSON.Key, Value:BSONDecodable
{
    /// Decodes an unordered dictionary from the given document. Dictionaries
    /// are not ``BSONEncodable``, because round-tripping them loses the field
    /// ordering information.
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        let document:BSON.Document = try .init(bson: consume bson)

        self.init()
        try document.parse
        {
            (field:BSON.FieldDecoder<BSON.Key>) in

            if  case _? = self.updateValue(try field.decode(to: Value.self), forKey: field.key)
            {
                throw BSON.DocumentKeyError<String>.duplicate(field.key.rawValue)
            }
        }
    }
}
