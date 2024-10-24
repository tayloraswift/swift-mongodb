import MongoDB
import MongoTesting

enum ReplicatedConfiguration:MongoTestConfiguration
{
    typealias Login = Mongo.Guest

    static
    let members:Mongo.Seedlist =
    [
        "mongo-0": 27017,
        "mongo-1": 27017,
        "mongo-2": 27017,
        "mongo-3": 27017,
        "mongo-4": 27017,
        "mongo-5": 27017,
        "mongo-6": 27017,
    ]

    static
    func configure(options:inout Mongo.DriverOptions<Never>)
    {
        options.connectionTimeout = .milliseconds(1000)
    }
}
extension ReplicatedConfiguration
{
    static
    let servers:[Mongo.ReadPreference] =
    [
        .primary,
        //  We should be able to run these tests on a specific server.
        .nearest(tagSets: [["name": "B"]]),
        //  We should be able to run these tests on a secondary.
        .nearest(tagSets: [["name": "C"]]),
    ]
}
