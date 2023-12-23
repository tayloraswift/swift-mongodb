import BSON
import MongoDriver

extension Mongo
{
    @frozen public
    enum Many:Mongo.WriteEffect
    {
        public
        typealias ExecutionPolicy = Mongo.Once
        public
        typealias DeletePlurality = Mongo.DeleteLimit
        public
        typealias UpdatePlurality = Bool
    }
}
