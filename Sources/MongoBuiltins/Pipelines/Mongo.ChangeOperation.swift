extension Mongo
{
    @frozen public
    enum ChangeOperation<Document, DocumentUpdate>
    {
        case insert(Document)
        case update(DocumentUpdate, before:Document?, after:Document?)

        case _unimplemented
    }
}
extension Mongo.ChangeOperation:Sendable where Document:Sendable, DocumentUpdate:Sendable
{
}
extension Mongo.ChangeOperation:Equatable where Document:Equatable, DocumentUpdate:Equatable
{
}
