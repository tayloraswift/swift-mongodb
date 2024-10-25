import MongoConfiguration

extension Mongo.Seedlist
{
    static var standalone:Self
    {
        ["mongo-single": 27017]
    }
    static var replicated:Self
    {
         [
            "mongo-0": 27017,
            "mongo-1": 27017,
            "mongo-2": 27017,
            "mongo-3": 27017,
            "mongo-4": 27017,
            "mongo-5": 27017,
            "mongo-6": 27017,
        ]
    }
}
