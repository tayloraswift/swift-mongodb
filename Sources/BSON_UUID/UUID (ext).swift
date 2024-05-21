import BSON
import UUID

extension UUID:BSONDecodable, BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        try bson.subtype.expect(.uuid)
        try bson.shape.expect(length: 16)

        self.init(bson.bytes)
    }
}
extension UUID:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(binary: BSON.BinaryView<Self>.init(subtype: .uuid, bytes: self))
    }
}
