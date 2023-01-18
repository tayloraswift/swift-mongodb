import BSON
import MongoChannel
import MongoWire
import NIOCore

extension Mongo
{
    public final
    class Connection
    {
        @usableFromInline
        let channel:MongoChannel

        let generation:UInt

        @usableFromInline
        var reusable:Bool

        init(generation:UInt, channel:MongoChannel)
        {
            self.channel = channel

            self.generation = generation
            self.reusable = true
        }
    }
}
extension Mongo.Connection
{
    @inlinable public
    func run<Command>(command:__owned Command,
        against database:Command.Database,
        labels:Mongo.SessionLabels? = nil,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
        where Command:MongoCommand
    {
        let message:MongoWire.Message<ByteBufferView>?
        do
        {
            message = try await self.channel.run(
                command: .init { command.encode(to: &$0, database: database, labels: labels) },
                by: deadline)
        }
        catch let error
        {
            self.reusable = false
            throw error
        }
        if  let message:MongoWire.Message<ByteBufferView>
        {
            return try .init(message: message)
        }
        else
        {
            throw MongoChannel.TimeoutError.init()
        }
    }
}
