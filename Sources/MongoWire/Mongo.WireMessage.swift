import BSON
import CRC

extension Mongo
{
    @frozen public
    struct WireMessage<Bytes> where Bytes:RandomAccessCollection<UInt8>
    {
        public
        let header:WireHeader
        public
        let flags:WireFlags
        public
        let sections:Sections
        public
        let checksum:CRC32?

        @inlinable public
        init(header:WireHeader, flags:WireFlags, sections:Sections, checksum:CRC32?)
        {
            self.header = header
            self.flags = flags
            self.sections = sections
            self.checksum = checksum
        }
    }
}
extension Mongo.WireMessage:Sendable where Bytes:Sendable
{
}
extension Mongo.WireMessage:Identifiable
{
    @inlinable public
    var id:Mongo.WireMessageIdentifier { self.header.id }
}
extension Mongo.WireMessage
{
    @inlinable public
    init(sections:Sections, checksum:Bool = false, id:Mongo.WireMessageIdentifier)
    {
        // 4 bytes of flags + 1 for body section type
        var count:Int = 4 + 1 + sections.body.size

        for outline:Outline in sections.outlined
        {
            // section type
            count += 1
            count += outline.size
        }

        let flags:Mongo.WireFlags
        let crc32:CRC32?
        if checksum
        {
            count += 4
            flags = [.checksumPresent]
            fatalError("unimplemented")
        }
        else
        {
            flags = []
            crc32 = nil
        }

        self.init(header: .init(count: count, id: id), flags: flags,
            sections: sections,
            checksum: crc32)
    }
}
