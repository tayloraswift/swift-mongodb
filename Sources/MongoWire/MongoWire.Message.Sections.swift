import BSON
import BSON
import BSON

extension MongoWire.Message
{
    @frozen public
    struct Sections
    {
        public
        let body:BSON.DocumentView<Bytes>
        public
        let outlined:[Outline]

        @inlinable public
        init(body:BSON.DocumentView<Bytes>, outlined:[Outline] = [])
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
        as _:MongoWire.Message<Source.SubSequence>.Sections.Type =
            MongoWire.Message<Source.SubSequence>.Sections.self)
        throws -> MongoWire.Message<Source.SubSequence>.Sections
    {
        var body:BSON.DocumentView<Source.SubSequence>? = nil
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
                    body = try self.parse(as: BSON.DocumentView<Source.SubSequence>.self)
                }
                else
                {
                    throw MongoWire.BodyCountError.multiple
                }
            
            case .sequence:
                var sequence:BSON.Input<Source.SubSequence> = .init(
                    try self.parse(MongoWire.SequenceFrame.self))
                
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

        for outline:MongoWire.Message<Bytes>.Outline in sections.outlined
        {
            self.append(MongoWire.Section.sequence.rawValue)

            self.serialize(integer: Int32.init(outline.size))
            self.serialize(cString: outline.id)
            self.append(outline.slice)
        }
    }
}
