extension Mongo
{
    public
    protocol ExecutionPolicy
    {
        static
        func retry<Success>(selecting preference:ReadPreference,
            among deployment:Deployment,
            until deadline:ContinuousClock.Instant?,
            operation:(ConnectionPool, Deadlines) async throws -> Success)
            async throws -> Success
    }
}
