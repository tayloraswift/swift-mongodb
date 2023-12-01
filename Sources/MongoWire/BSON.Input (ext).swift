import BSON
import CRC

extension BSON.Input
{
    @inlinable public mutating
    func parse(
        as _:Mongo.WireHeader.Type = Mongo.WireHeader.self) throws -> Mongo.WireHeader
    {
        // total size, including this
        let size:Int32 = try self.parse(as: Int32.self)
        let id:Int32 = try self.parse(as: Int32.self)
        let request:Int32 = try self.parse(as: Int32.self)
        let type:Int32 = try self.parse(as: Int32.self)
        return try .init(size: size, id: id, request: request, type: type)
    }
}
extension BSON.Input
{
    @inlinable public mutating
    func parse(
        as _:Mongo.WireMessage<Source.SubSequence>.Sections.Type =
            Mongo.WireMessage<Source.SubSequence>.Sections.self)
        throws -> Mongo.WireMessage<Source.SubSequence>.Sections
    {
        var body:BSON.DocumentView<Source.SubSequence>? = nil
        var outlined:[Mongo.WireMessage<Source.SubSequence>.Outline] = []

        while let section:UInt8 = self.next()
        {
            guard let section:Mongo.WireSection = .init(rawValue: section)
            else
            {
                throw Mongo.WireSectionError.init(invalid: section)
            }
            switch section
            {
            case .body:
                if case nil = body
                {
                    body = try self.parse(as: BSON.DocumentView<Source.SubSequence>.self)
                }
                else
                {
                    throw Mongo.WireBodyCountError.multiple
                }

            case .sequence:
                var sequence:BSON.Input<Source.SubSequence> = .init(
                    try self.parse(Mongo.WireSequenceFrame.self))

                let id:String = try sequence.parse(as: String.self)

                outlined.append(.init(id: id, slice: sequence.remaining))
            }
        }

        //  '''
        //  A fully constructed OP_MSG MUST contain exactly one Payload Type 0, and optionally
        //  any number of Payload Type 1 where each identifier MUST be unique per message.
        //  '''
        guard let body:BSON.DocumentView<Source.SubSequence>
        else
        {
            throw Mongo.WireBodyCountError.none
        }

        return .init(body: body, outlined: outlined)
    }
}
extension BSON.Input
{
    @inlinable public mutating
    func parse(
        as _:Mongo.WireMessage<Source.SubSequence>.Type =
            Mongo.WireMessage<Source.SubSequence>.self,
        header:Mongo.WireHeader) throws -> Mongo.WireMessage<Source.SubSequence>
    {
        let flags:Mongo.WireFlags = try .init(validating: try self.parse(as: UInt32.self))

        let sections:Mongo.WireMessage<Source.SubSequence>.Sections = try self.parse(
            as: Mongo.WireMessage<Source.SubSequence>.Sections.self)

        let checksum:CRC32? = flags.contains(.checksumPresent) ?
            .init(checksum: try self.parse(as: UInt32.self)) : nil

        return .init(header: header, flags: flags, sections: sections, checksum: checksum)
    }
}
