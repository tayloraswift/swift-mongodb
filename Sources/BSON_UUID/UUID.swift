import UUID
import BSONSchema

extension UUID:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.Binary<some RandomAccessCollection<UInt8>>) throws
    {
        guard case .uuid = bson.subtype
        else
        {
            throw BSON.BinarySchemeError.subtype(invalid: bson.subtype)
        }
        guard bson.bytes.count == 16
        else
        {
            throw BSON.BinarySchemeError.shape(invalid: bson.bytes.count, expected: 16)
        }
        
        self.init(bson.bytes)
    }
}
extension UUID:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(binary: .init(subtype: .uuid, bytes: self))
    }
}
