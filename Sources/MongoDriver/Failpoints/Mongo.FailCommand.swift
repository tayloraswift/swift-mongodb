import BSONEncoding

extension Mongo
{
    /// See: https://github.com/mongodb/mongo/wiki/The-%22failCommand%22-fail-point
    public
    struct FailCommand:Sendable
    {
        public
        let behavior:Behavior?
        public
        let appname:String?
        public
        let types:[any MongoCommand.Type]

        public
        init(behavior:Behavior?, appname:String?, types:[any MongoCommand.Type])
        {
            self.behavior = behavior
            self.appname = appname
            self.types = types
        }
    }
}

extension Mongo.FailCommand:MongoFailpoint
{
    /// The string [`"failCommand"`]().
    @inlinable public static
    var name:String
    {
        "failCommand"
    }
}
extension Mongo.FailCommand:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson["appName"] = self.appname
        bson["failCommands"] = self.types.map { $0.name }

        switch self.behavior
        {
        case .blockConnection(for: let milliseconds, then: let mode)?:
            if  milliseconds > 0
            {
                bson["blockConnection"] = true
                bson["blockTimeMS"] = milliseconds
            }
            switch mode
            {
            case .error(let code):
                bson["errorCode"] = code
            
            case .writeConcernError(let error):
                bson["writeConcernError"] = error
            }
        
        case .closeConnection?:
            bson["closeConnection"] = true
        
        case nil:
            break
        }
    }
}
