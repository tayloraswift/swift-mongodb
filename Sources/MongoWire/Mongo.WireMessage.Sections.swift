import BSON

extension Mongo.WireMessage
{
    @frozen public
    struct Sections:Sendable
    {
        public
        let body:BSON.DocumentView<ArraySlice<UInt8>>
        public
        let outlined:[Outline]

        @inlinable public
        init(body:BSON.DocumentView<ArraySlice<UInt8>>, outlined:[Outline] = [])
        {
            self.body = body
            self.outlined = outlined
        }
    }
}
extension Mongo.WireMessage.Sections
{
    @inlinable internal static
    func parse(from input:inout BSON.Input<[UInt8]>) throws -> Self
    {
        var body:BSON.DocumentView<ArraySlice<UInt8>>? = nil
        var outlined:[Mongo.WireMessage.Outline] = []

        while let section:UInt8 = input.next()
        {
            guard
            let section:Mongo.WireSection = .init(rawValue: section)
            else
            {
                throw Mongo.WireSectionError.init(invalid: section)
            }
            switch section
            {
            case .body:
                guard case nil = body
                else
                {
                    throw Mongo.WireBodyCountError.multiple
                }

                body = try input.parse(as: BSON.DocumentView<ArraySlice<UInt8>>.self)

            case .sequence:
                var sequence:BSON.Input<ArraySlice<UInt8>> = .init(try input.parse(
                    Mongo.WireSequenceFrame.self))

                let id:String = try sequence.parse(as: String.self)

                outlined.append(.init(id: id, slice: sequence.remaining))
            }
        }

        //  '''
        //  A fully constructed OP_MSG MUST contain exactly one Payload Type 0, and optionally
        //  any number of Payload Type 1 where each identifier MUST be unique per message.
        //  '''
        guard
        let body:BSON.DocumentView<ArraySlice<UInt8>>
        else
        {
            throw Mongo.WireBodyCountError.none
        }

        return .init(body: body, outlined: outlined)
    }
}
extension Mongo.WireMessage.Sections
{
    @inlinable internal static
    func += (output:inout BSON.Output<some RangeReplaceableCollection<UInt8>>, self:Self)
    {
        output.append(Mongo.WireSection.body.rawValue)
        output.serialize(document: self.body)

        for outline:Mongo.WireMessage.Outline in self.outlined
        {
            output.append(Mongo.WireSection.sequence.rawValue)

            output.serialize(integer: Int32.init(outline.size))
            output.serialize(cString: outline.id)
            output.append(outline.slice)
        }
    }
}
