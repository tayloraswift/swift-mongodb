import BSON
import CRC

extension BSON.Output
{
    @inlinable public mutating
    func serialize(header:Mongo.WireHeader)
    {
        // the `as` coercions are here to prevent us from accidentally
        // changing the types of the various integers, which ``serialize(integer:)``
        // depends on.
        self.serialize(integer: header.size as Int32)
        self.serialize(integer: header.id.value as Int32)
        self.serialize(integer: header.request.value as Int32)
        self.serialize(integer: header.type.rawValue as Int32)
    }
}
extension BSON.Output
{
    @inlinable public mutating
    func serialize<Bytes>(sections:Mongo.WireMessage<Bytes>.Sections)
    {
        self.append(Mongo.WireSection.body.rawValue)
        self.serialize(document: sections.body)

        for outline:Mongo.WireMessage<Bytes>.Outline in sections.outlined
        {
            self.append(Mongo.WireSection.sequence.rawValue)

            self.serialize(integer: Int32.init(outline.size))
            self.serialize(cString: outline.id)
            self.append(outline.slice)
        }
    }
}
extension BSON.Output
{
    @inlinable public mutating
    func serialize(message:Mongo.WireMessage<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(header: message.header)
        self.serialize(integer: message.flags.rawValue as UInt32)
        self.serialize(sections: message.sections)
        if let crc32:CRC32 = message.checksum
        {
            self.serialize(integer: crc32.checksum as UInt32)
        }
    }
}
