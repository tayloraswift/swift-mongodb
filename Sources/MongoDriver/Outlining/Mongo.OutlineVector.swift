import BSONEncoding

extension Mongo
{
    /// A payload is an efficient means of encoding long sequences of BSON
    /// documents. Payloads are subject to the maximum wire message size,
    /// which is usually 48 MB, and larger than the maximum BSON document
    /// size, which is usually 16 MB.
    @frozen public
    struct OutlineVector:Sendable
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
extension Mongo.OutlineVector
{
    var slice:[UInt8]
    {
        self.output.destination
    }
}
extension Mongo.OutlineVector
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
    @inlinable public
    init<Element>(_ elements:some Sequence<Element>)
        where Element:BSONRepresentable<BSON.Document>
    {
        self.init()
        for element:Element in elements
        {
            self.append(BSON.DocumentView<[UInt8]>.init(element.bson))
        }
    }
}
extension Mongo.OutlineVector
{
    @inlinable public mutating
    func append<CodingKeys>(_ element:some BSONDocumentEncodable<CodingKeys>)
    {
        element.encode(to: &self.output[
            as: BSON.DocumentEncoder<CodingKeys>.self,
            in: BSON.DocumentFrame.self])
    }
    public mutating
    func append(_ document:BSON.DocumentView<[UInt8]>)
    {
        self.output.serialize(document: document)
    }
}
