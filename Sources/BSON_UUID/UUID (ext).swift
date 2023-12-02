import BSON
import UUID

extension UUID:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<some RandomAccessCollection<UInt8>>) throws
    {
        try bson.subtype.expect(.uuid)
        try bson.shape.expect(length: 16)

        self.init(bson.slice)
    }
}
extension UUID:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(binary: .init(subtype: .uuid, slice: self))
    }
}
