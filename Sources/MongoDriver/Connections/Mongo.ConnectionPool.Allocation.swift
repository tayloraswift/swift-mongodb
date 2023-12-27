import BSON
import MongoExecutor
import NIOCore

extension Mongo.ConnectionPool
{
    @usableFromInline internal
    struct Allocation:MongoExecutor, Sendable
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
extension Mongo.ConnectionPool.Allocation
{
    /// Runs an authentication command against the specified `database`,
    /// and decodes its response.
    func run(saslStart command:__owned Mongo.SASLStart,
        against database:Mongo.Database,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.SASLResponse
    {
        try .init(bson: try await self.run(command: command, against: database, by: deadline)())
    }
    /// Runs an authentication command against the specified `database`,
    /// and decodes its response.
    func run(saslContinue command:__owned Mongo.SASLContinue,
        against database:Mongo.Database,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.SASLResponse
    {
        try .init(bson: try await self.run(command: command, against: database, by: deadline)())
    }
    /// Runs a ``Mongo/Hello`` command, and decodes a subset of its response
    /// suitable for authentication purposes.
    func run(hello command:__owned Mongo.Hello,
        by deadline:ContinuousClock.Instant) async throws -> Set<Mongo.Authentication.SASL>?
    {
        let bson:BSON.DocumentDecoder<BSON.Key, ArraySlice<UInt8>> = try await self.run(
            command: command,
            against: .admin,
            by: deadline)()
        return try bson["saslSupportedMechs"]?.decode(to: Set<Mongo.Authentication.SASL>.self)
    }
}
