import BSON
import UUID

extension UUID:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        try bson.subtype.expect(.uuid)
        try bson.shape.expect(length: 16)

        self.init(bson.bytes)
    }
}
extension UUID:BSONBinaryEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.subtype = .uuid
        bson.reserve(another: 16)
        bson += self
    }
}
