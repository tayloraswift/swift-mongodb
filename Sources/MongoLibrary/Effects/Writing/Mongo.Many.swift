import BSONEncoding
import MongoDriver

extension Mongo
{
    @frozen public
    enum Many:MongoWriteEffect
    {
        public
        typealias ExecutionPolicy = Mongo.Once
        public
        typealias DeletePlurality = Mongo.DeleteLimit
        public
        typealias UpdatePlurality = Bool
    }
}
