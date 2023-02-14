import BSONDecoding
import NIOCore

extension Mongo
{
    public
    enum Explain<Response> where Response:Sendable & BSONDictionaryDecodable
    {
    }
}
extension Mongo.Explain:MongoBatchingMode
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
