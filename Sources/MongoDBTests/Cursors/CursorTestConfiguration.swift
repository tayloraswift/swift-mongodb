import MongoDB
import MongoTesting

protocol CursorTestConfiguration:MongoTestConfiguration
{
    static
    var servers:[Mongo.ReadPreference] { get }
}
