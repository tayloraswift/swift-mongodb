extension Mongo
{
    public
    typealias ExecutionPolicy = _MongoExecutionPolicy
}

/// The name of this protocol is ``Mongo.ExecutionPolicy``.
public
protocol _MongoExecutionPolicy
{
    static
    func retry<Success>(selecting preference:Mongo.ReadPreference,
        among deployment:Mongo.Deployment,
        until deadline:ContinuousClock.Instant?,
        operation:(Mongo.ConnectionPool, Mongo.Deadlines) async throws -> Success)
        async throws -> Success
}
