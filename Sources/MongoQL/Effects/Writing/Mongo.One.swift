import BSON

extension Mongo
{
    @frozen public
    enum One:Mongo.WriteEffect
    {
        public
        typealias ExecutionPolicy = Mongo.Retry
        public
        typealias DeletePlurality = Mongo.DeleteOne
        public
        typealias UpdatePlurality = Never
    }
}
