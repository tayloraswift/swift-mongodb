import UUID
import BSONDecoding
import BSONEncoding

extension UUID:BSONDecodable, BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.Binary<some RandomAccessCollection<UInt8>>) throws
    {
        guard case .uuid = bson.subtype
        else
        {
            throw BSON.BinarySchemeError.subtype(invalid: bson.subtype)
        }
        guard bson.slice.count == 16
        else
        {
            throw BSON.BinarySchemeError.shape(invalid: bson.slice.count, expected: 16)
        }
        
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
