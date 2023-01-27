import BSONEncoding

extension Mongo
{
    /// See: https://github.com/mongodb/mongo/wiki/The-%22failCommand%22-fail-point
    public
    struct FailCommand:Sendable
    {
        public
        let application:String?
        public
        let behavior:Behavior?
        public
        let types:[any MongoCommand.Type]

        public
        init(application:String?, behavior:Behavior?, types:[any MongoCommand.Type])
        {
            self.application = application
            self.behavior = behavior
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

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["appName"] = self.application
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
            case .code(let error):
                bson["errorCode"] = error
            
            case .writeConcern(let error):
                bson["writeConcernError"] = error
            }
        
        case .closeConnection?:
            bson["closeConnection"] = true
        
        case nil:
            break
        }
    }
}
