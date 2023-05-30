import BSONEncoding
import MongoDriver

extension Mongo
{
    @frozen public
    enum One:MongoWriteEffect
    {
        public
        typealias ExecutionPolicy = Mongo.Retry
        public
        typealias DeletePlurality = Mongo.DeleteOne
        public
        typealias UpdatePlurality = Never
    }
}
