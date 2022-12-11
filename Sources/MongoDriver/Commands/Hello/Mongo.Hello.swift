import BSONEncoding

extension Mongo
{
    struct Hello:Sendable
    {
        let client:BSON.Fields?
        let user:User?

        init(client:BSON.Fields? = nil, user:User?)
        {
            self.client = client
            self.user = user
        }
    }
}
extension Mongo.Hello
{
    static
    let client:BSON.Fields = .init
    {
        $0["driver"] = .init
        {
            $0["name"] = "swift-mongodb"
            $0["version"] = "0"
        }
        $0["os"] = .init
        {
            $0["type"] = Self.os
        }
    }
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
extension Mongo.Hello:MongoCommand
{
    func encode(to bson:inout BSON.Fields)
    {
        bson["hello"] = true
        bson["client"] = self.client
        bson["saslSupportedMechs"] = self.user
    }
}
