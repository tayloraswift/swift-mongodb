extension Mongo
{
    @frozen public
    enum Retry
    {
    }
}
extension Mongo.Retry:MongoExecutionPolicy
{
    @inlinable public static
    func retry<Success>(selecting preference:Mongo.ReadPreference,
        among deployment:Mongo.Deployment,
        until deadline:ContinuousClock.Instant?,
        operation:(Mongo.ConnectionPool, Mongo.Deadlines) async throws -> Success)
        async throws -> Success
    {
        let deadline:ContinuousClock.Instant = deadline ?? deployment.timeout.deadline()

        var reported:(any MongoRetryableError)? = nil

        trying:
        while true
        {
            let deadlines:Mongo.Deadlines = deployment.timeout.deadlines(clamping: deadline)

            let pool:Mongo.ConnectionPool = try await deployment.pool(selecting: preference,
                by: deadlines.connection)

            do
            {
                return try await operation(pool, deadlines)
            }
            catch let error
            {
                if case let error as any MongoRetryableError = error,
                            error.isRetryable
                {
                    reported = error
                    continue trying
                }
                else
                {
                    throw reported ?? error
                }
            }
        }
    }
}
