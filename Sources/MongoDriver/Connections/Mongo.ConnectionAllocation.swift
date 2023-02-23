import MongoExecutor
import NIOCore

extension Mongo
{
    @usableFromInline internal
    struct ConnectionAllocation:MongoExecutor, Sendable
    {
        @usableFromInline internal
        let channel:any Channel
        let id:UInt

        init(channel:any Channel, id:UInt)
        {
            self.channel = channel
            self.id = id
        }
    }
}
extension Mongo.ConnectionAllocation
{
    /// Runs an authentication command against the specified `database`,
    /// and decodes its response.
    func run(saslStart command:__owned Mongo.SASLStart,
        against database:Mongo.Database,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.SASLResponse
    {
        try .init(bson: try await self.run(command: command, against: database,
            by: deadline.instant)())
    }
    /// Runs an authentication command against the specified `database`,
    /// and decodes its response.
    func run(saslContinue command:__owned Mongo.SASLContinue,
        against database:Mongo.Database,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.SASLResponse
    {
        try .init(bson: try await self.run(command: command, against: database,
            by: deadline.instant)())
    }
    /// Runs a ``Mongo/Hello`` command, and decodes a subset of its response
    /// suitable for authentication purposes.
    func run(hello command:__owned Mongo.Hello,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.Authentication.HelloResponse
    {
        try .init(bson: try await self.run(command: command, against: .admin,
            by: deadline.instant)())
    }
}
