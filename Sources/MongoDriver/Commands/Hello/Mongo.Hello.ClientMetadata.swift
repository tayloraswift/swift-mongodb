import BSONEncoding

extension Mongo.Hello
{
    struct ClientMetadata:Sendable
    {
        let appname:String?

        init(appname:String?)
        {
            self.appname = appname
        }
    }
}
extension Mongo.Hello.ClientMetadata
{
    private static
    var os:String
    {
        #if os(Linux)
        "Linux"
        #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        "Darwin"
        #elseif os(Windows)
        "Windows"
        #else
        "unknown"
        #endif
    }
}
extension Mongo.Hello.ClientMetadata:BSONEncodable, BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        if let appname:String = self.appname
        {
            bson["application"]
            {
                $0["name"] = appname
            }
        }
        bson["driver"]
        {
            $0["name"] = "swift-mongodb"
            $0["version"] = "0"
        }
        bson["os"]
        {
            $0["type"] = Self.os
        }
    }
}
