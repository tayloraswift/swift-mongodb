import BSONDecoding

extension Mongo.Authentication
{
    /// Models a subset of the fields returned by the server for a ``Hello`` command.
    struct HelloResponse:Sendable
    {
        let mechanisms:Set<SASL>?

        private
        init(mechanisms:Set<SASL>?)
        {
            self.mechanisms = mechanisms
        }
    }
}
extension Mongo.Authentication.HelloResponse:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<String, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(mechanisms: try bson["saslSupportedMechs"]?.decode(
            to: Set<Mongo.Authentication.SASL>.self))
    }
}
