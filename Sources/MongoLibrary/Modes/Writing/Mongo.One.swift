import MongoDriver

extension Mongo
{
    @frozen public
    enum One:MongoOverwriteMode
    {
        public
        typealias ExecutionPolicy = Mongo.Retry
    }
}
