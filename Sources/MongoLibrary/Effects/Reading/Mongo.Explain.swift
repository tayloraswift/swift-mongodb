import BSONDecoding
import NIOCore

extension Mongo
{
    @frozen public
    enum Explain<Response> where Response:Sendable & BSONDocumentDecodable<BSON.Key>
    {
    }
}
extension Mongo.Explain:MongoReadEffect
{
    public
    typealias CommandResponse = Response
    public
    typealias Element = Never
    public
    typealias Tailing = Never
    public
    typealias Stride = Void
}
