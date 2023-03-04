public
protocol MongoExecutionPolicy
{
    static
    func retry<Success>(selecting preference:Mongo.ReadPreference,
        among deployment:Mongo.Deployment,
        until deadline:ContinuousClock.Instant?,
        operation:(Mongo.ConnectionPool, Mongo.Deadlines) async throws -> Success)
        async throws -> Success
}
