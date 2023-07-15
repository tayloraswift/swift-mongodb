extension Optional:BSONEncodable where Wrapped:BSONEncodable
{
    /// Encodes this optional as an explicit ``BSON.null``, if nil.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        if let self:Wrapped
        {
            self.encode(to: &field)
        }
        else
        {
            field.encode(null: ())
        }
    }
}
//  These APIs must additionally be extensions on ``Optional`` and not just
//  ``BSONEncodable`` because SE-299 does not support protocol extension
//  member lookup with unnamed closure parameters. Only the APIs that take
//  closure arguments need to be duplicated here.
extension BSON.Document?
{
    @inlinable public
    init<CodingKey>(_:CodingKey.Type = CodingKey.self,
        with populate:(inout BSON.DocumentEncoder<CodingKey>) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
    @inlinable public
    init(with populate:(inout BSON.DocumentEncoder<BSON.Key>) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
extension BSON.List?
{
    @inlinable public
    init(with populate:(inout BSON.ListEncoder) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
