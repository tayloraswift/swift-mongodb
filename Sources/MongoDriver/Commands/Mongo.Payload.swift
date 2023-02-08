import BSONEncoding

extension Mongo
{
    /// A payload is an efficient means of encoding long sequences of BSON
    /// documents. Payloads are subject to the maximum wire message size,
    /// which is usually 48 MB, and larger than the maximum BSON document
    /// size, which is usually 16 MB.
    @frozen public
    struct Payload:Sendable, Identifiable
    {
        public
        let id:ID

        @usableFromInline
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init(id:ID)
        {
            self.id = id
            self.output = .init(preallocated: [])
        }
    }
}
extension Mongo.Payload
{
    @inlinable public mutating
    func append(_ element:some BSONDocumentEncodable)
    {
        self.append(.init(BSON.Fields.init(with: element.encode(to:))))
    }
    public mutating
    func append(_ document:BSON.Document<[UInt8]>)
    {
        self.output.serialize(document: document)
    }
}
