import BSON

extension MongoWire.Message
{
    @frozen public
    struct Sections
    {
        public
        let body:BSON.Document<Bytes>
        public
        let outlined:[Outline]

        @inlinable public
        init(body:BSON.Document<Bytes>, outlined:[Outline] = [])
        {
            self.body = body
            self.outlined = outlined
        }
    }
}
extension MongoWire.Message.Sections:Sendable where Bytes:Sendable
{
}

extension BSON.Input
{
    @inlinable public mutating
    func parse(
        as _:MongoWire.Message<Source.SubSequence>.Sections.Type = MongoWire.Message<Source.SubSequence>.Sections.self)
        throws -> MongoWire.Message<Source.SubSequence>.Sections
    {
        var body:BSON.Document<Source.SubSequence>? = nil
        var outlined:[MongoWire.Message<Source.SubSequence>.Outline] = []

        while let section:UInt8 = self.next()
        {
            guard let section:MongoWire.Section = .init(rawValue: section)
            else
            {
                throw MongoWire.SectionError.init(invalid: section)
            }
            switch section
            {
            case .body:
                if case nil = body
                {
                    body = try self.parse(as: BSON.Document<Source.SubSequence>.self)
                }
                else
                {
                    throw MongoWire.BodyCountError.multiple
                }
            
            case .sequence:
                let sequence:MongoWire.Message<Source.SubSequence>.Sequence = try self.parse(
                    as: MongoWire.Message<Source.SubSequence>.Sequence.self)
                outlined.append(try sequence.parse())
            }
        }

        //  '''
        //  A fully constructed OP_MSG MUST contain exactly one Payload Type 0, and optionally
        //  any number of Payload Type 1 where each identifier MUST be unique per message.
        //  '''
        guard let body:BSON.Document<Source.SubSequence>
        else
        {
            throw MongoWire.BodyCountError.none
        }

        return .init(body: body, outlined: outlined)
    }
}

extension BSON.Output
{
    @inlinable public mutating
    func serialize<Bytes>(sections:MongoWire.Message<Bytes>.Sections)
    {
        self.append(MongoWire.Section.body.rawValue)
        self.serialize(document: sections.body)

        for section:MongoWire.Message<Bytes>.Outline in sections.outlined
        {
            self.append(MongoWire.Section.sequence.rawValue)
            // TODO: get rid of this intermediate buffer
            let sequence:MongoWire.Message<[UInt8]>.Sequence = .init(id: section.id,
                documents: section.documents)
            self.serialize(integer: sequence.header as Int32)
            self.append(sequence.bytes)
        }
    }
}
