import BSONEncoding

extension Mongo.Payload
{
    /// A payload is an efficient means of encoding long sequences of BSON
    /// documents. Payloads are subject to the maximum wire message size,
    /// which is usually 48 MB, and larger than the maximum BSON document
    /// size, which is usually 16 MB.
    @frozen public
    struct Documents:Sendable
    {
        @usableFromInline
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init()
        {
            self.output = .init(preallocated: [])
        }
    }
}
extension Mongo.Payload.Documents
{
    var slice:[UInt8]
    {
        self.output.destination
    }
}
extension Mongo.Payload.Documents
{
    @inlinable public
    init<Encodable>(_ elements:some Sequence<Encodable>) where Encodable:BSONDocumentEncodable
    {
        self.init()
        for element:Encodable in elements
        {
            self.append(element)
        }
    }
}
extension Mongo.Payload.Documents
{
    @inlinable public mutating
    func append(_ element:some BSONDocumentEncodable)
    {
        self.append(.init(BSON.Fields.init(with: element.encode(to:))))
    }
    public mutating
    func append(_ document:BSON.DocumentView<[UInt8]>)
    {
        self.output.serialize(document: document)
    }
}
