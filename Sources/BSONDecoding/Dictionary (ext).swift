extension Dictionary:BSONDocumentViewDecodable, BSONDecodable
    where Key == BSON.Key, Value:BSONDecodable
{
    /// Decodes an unordered dictionary from the given document. Dictionaries
    /// are not ``BSONEncodable``, because round-tripping them loses the field
    /// ordering information.
    @inlinable public
    init(bson:BSON.DocumentView) throws
    {
        self.init()
        try bson.parse
        {
            (field:BSON.FieldDecoder<BSON.Key>) in

            if  case _? = self.updateValue(try field.decode(to: Value.self), forKey: field.key)
            {
                throw BSON.DocumentKeyError<String>.duplicate(field.key.rawValue)
            }
        }
    }
}
