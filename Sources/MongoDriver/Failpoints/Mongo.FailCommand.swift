import BSON
import MongoCommands

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
        let types:[CommandType]

        public
        init(behavior:Behavior?, appname:String?, types:[CommandType])
        {
            self.behavior = behavior
            self.appname = appname
            self.types = types
        }
    }
}

extension Mongo.FailCommand:Mongo.Failpoint
{
    /// The string `"failCommand"`.
    @inlinable public static
    var name:String { "failCommand" }
}
extension Mongo.FailCommand:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson["appName"] = self.appname
        bson["failCommands"] = self.types

        switch self.behavior
        {
        case .blockConnection(for: let milliseconds, then: let mode)?:
            if  milliseconds > .zero
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
