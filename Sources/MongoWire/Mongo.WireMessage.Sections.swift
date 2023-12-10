import BSON

extension Mongo.WireMessage
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
extension Mongo.WireMessage.Sections:Sendable where Bytes:Sendable
{
}
