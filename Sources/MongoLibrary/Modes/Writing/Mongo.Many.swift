import MongoDriver

extension Mongo
{
    @frozen public
    enum Many:MongoOverwriteMode
    {
        public
        typealias ExecutionPolicy = Mongo.Once
    }
}
