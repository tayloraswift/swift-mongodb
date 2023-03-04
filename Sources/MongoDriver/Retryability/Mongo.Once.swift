extension Mongo
{
    @frozen public
    enum Once
    {
    }
}
extension Mongo.Once:MongoExecutionPolicy
{
    @inlinable public static
    func retry<Success>(selecting preference:Mongo.ReadPreference,
        among deployment:Mongo.Deployment,
        until deadline:ContinuousClock.Instant?,
        operation:(Mongo.ConnectionPool, Mongo.Deadlines) async throws -> Success)
        async throws -> Success
    {
        let deadlines:Mongo.Deadlines = deployment.timeout.deadlines(clamping: deadline)

        let pool:Mongo.ConnectionPool = try await deployment.pool(selecting: preference,
            by: deadlines.connection)
            
        return try await operation(pool, deadlines)
    }
}
