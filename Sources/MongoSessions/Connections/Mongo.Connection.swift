import BSONEncoding
import Heartbeats
import MongoWire
import NIOCore
import NIOPosix
import NIOSSL
import SCRAM
import SHA2

extension Mongo
{
    /// @import(NIOCore)
    /// A connection to a `mongod`/`mongos` host. This type is an API wrapper around
    /// an NIO ``Channel``.
    ///
    /// > Warning: This type is not managed! If you are storing instances of this type, 
    /// there must be code elsewhere responsible for closing the wrapped NIO ``Channel``!
    @frozen public
    struct Connection:Sendable
    {
        private
        let channel:any Channel
        let heart:Heart

        private
        init(channel:any Channel, heart:Heart)
        {
            self.channel = channel
            self.heart = heart
        }
        func close()
        {
            self.channel.close(mode: .all, promise: nil)
        }
    }
}
extension Mongo.Connection
{
    static
    func === (lhs:Self, rhs:Self) -> Bool
    {
        lhs.channel === rhs.channel
    }
    static
    func !== (lhs:Self, rhs:Self) -> Bool
    {
        lhs.channel !== rhs.channel
    }
}

extension Mongo.Connection
{
    /// Sets up a TCP channel to the given host that will stop the given
    /// heartbeat if the channel is closed (for any reason). The heart
    /// will not be stopped if the channel cannot be created in the first
    /// place; the caller is responsible for disposing of the heartbeat
    /// if this constructor throws an error.
    init(driver:Mongo.Driver, heart:Heart, host:Mongo.Host) async throws
    {
        let bootstrap:ClientBootstrap = .init(group: driver.executor)
            .resolver(driver.resolver)
            .channelOption(
                ChannelOptions.socket(SocketOptionLevel.init(SOL_SOCKET), SO_REUSEADDR), 
                value: 1)
            .channelInitializer
        { 
            (channel:any Channel) in

            let wire:ByteToMessageHandler<Mongo.MessageDecoder> = .init(.init())
            let router:Mongo.MessageRouter = .init(timeout: driver.timeout)

            guard let certificatePath:String = driver._certificatePath
            else
            {
                return channel.pipeline.addHandlers(wire, router)
            }
            do 
            {
                var configuration:TLSConfiguration = .clientDefault
                configuration.trustRoots = NIOSSLTrustRoots.file(certificatePath)
                
                let tls:NIOSSLClientHandler = try .init(
                    context: .init(configuration: configuration), 
                    serverHostname: host.name)
                return channel.pipeline.addHandlers(tls, wire, router)
            } 
            catch let error
            {
                return channel.eventLoop.makeFailedFuture(error)
            }
        }

        let channel:any Channel = try await bootstrap.connect(
            host: host.name,
            port: host.port).get()
        
        channel.closeFuture.whenComplete
        {
            //  when the checker task is cancelled, it will also close the
            //  connection again, which will be a no-op.
            switch $0
            {
            case .success(()):
                heart.stop()
            case .failure(let error):
                heart.stop(throwing: error)
            }
        }
        
        self.init(channel: channel, heart: heart)
    }
}

extension Mongo.Connection
{
    /// Establishes a connection, performing authentication with the given credentials,
    /// if possible. If establishment fails, the connection’s TCP channel will *not*
    /// be closed.
    func establish(credentials:Mongo.Credentials?,
        appname:String?) async throws -> Mongo.Hello.Response
    {
        let user:Mongo.User?
        // if we don’t have an explicit authentication mode, ask the server
        // what it supports (for the current user).
        if  let credentials:Mongo.Credentials,
            case nil = credentials.authentication
        {
            user = credentials.user
        } 
        else
        {
            user = nil
        }

        let response:Mongo.Hello.Response = try await self.run(command: .init(
            client: .init(appname: appname),
            user: user))

        if let credentials:Mongo.Credentials
        {
            do
            {
                try await self.authenticate(with: credentials,
                    mechanisms: response.saslSupportedMechs)
            }
            catch let error
            {
                throw Mongo.AuthenticationError.init(error, credentials: credentials)
            }
        }

        return response
    }
}

extension Mongo.Connection
{
    private
    func authenticate(with credentials:Mongo.Credentials,
        mechanisms:Set<Mongo.Authentication.SASL>?) async throws
    {
        let sasl:Mongo.Authentication.SASL
        switch credentials.authentication
        {
        case .sasl(let explicit)?:
            //  https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst
            //  '''
            //  When a user has specified a mechanism, regardless of the server version,
            //  the driver MUST honor this.
            //  '''
            sasl = explicit
        
        case let other?:
            throw Mongo.AuthenticationUnsupportedError.init(other)
        
        case nil:
            //  '''
            //  If SCRAM-SHA-256 is present in the list of mechanism, then it MUST be used
            //  as the default; otherwise, SCRAM-SHA-1 MUST be used as the default,
            //  regardless of whether SCRAM-SHA-1 is in the list. Drivers MUST NOT attempt
            //  to use any other mechanism (e.g. PLAIN) as the default.
            //
            //  If `saslSupportedMechs` is not present in the handshake response for
            //  mechanism negotiation, then SCRAM-SHA-1 MUST be used when talking to
            //  servers >= 3.0. Prior to server 3.0, MONGODB-CR MUST be used.
            //  '''
            if case true? = mechanisms?.contains(.sha256)
            {
                sasl = .sha256
            }
            else
            {
                sasl = .sha1
            }
        }

        switch sasl
        {
        case .sha256:
            try await self.authenticate(sasl: .sha256,
                database: credentials.database,
                username: credentials.username,
                password: credentials.password)
        
        case .sha1:
            // note: we need to hash the password per
            // https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst#scram-sha-1
            throw Mongo.AuthenticationUnsupportedError.init(.sasl(.sha1))
        
        case let other:
            throw Mongo.AuthenticationUnsupportedError.init(.sasl(other))
        }
    } 
    private
    func authenticate(sasl mechanism:Mongo.Authentication.SASL, 
        database:Mongo.Database, 
        username:String, 
        password:String) async throws 
    {
        let start:SCRAM.Start = .init(username: username)
        let first:Mongo.SASLResponse = try await self.run(
            command: Mongo.SASLStart.init(mechanism: mechanism, scram: start),
            against: database)
        
        if  first.done 
        {
            return
        }

        let challenge:SCRAM.Challenge = try .init(from: first.message)
        //  https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst
        //  '''
        //  Additionally, drivers MUST enforce a minimum iteration count of 4096 and
        //  MUST error if the authentication conversation specifies a lower count.
        //  This mitigates downgrade attacks by a man-in-the-middle attacker.
        //  '''
        guard 4096 ... 310_000 ~= challenge.iterations
        else
        {
            throw Mongo.PolicyError.sha256Iterations(challenge.iterations)
        }

        let client:SCRAM.ClientResponse<SHA256> = try .init(challenge: challenge,
            password: password,
            received: first.message,
            sent: start)
        let second:Mongo.SASLResponse = try await self.run(
            command: first.command(message: client.message),
            against: database)
        
        let server:SCRAM.ServerResponse = try .init(from: second.message)

        guard client.verify(server)
        else
        {
            throw Mongo.PolicyError.serverSignature
        }

        if  second.done 
        {
            return
        }
        
        let third:Mongo.SASLResponse = try await self.run(
            command: second.command(message: .init("")),
            against: database)
        
        guard third.done
        else 
        {
            throw Mongo.SASLConversationError.init()
        }
    }
}

extension Mongo.Connection
{
    /// Runs an authentication command against the specified `database`,
    /// and decodes its response.
    func run<Command>(command:__owned Command,
        against database:Mongo.Database) async throws -> Mongo.SASLResponse
        where Command:MongoAuthenticationCommand
    {
        try Command.decode(message: try await self.run(command: command,
            against: database))
    }
    /// Runs a ``Mongo/Hello`` command, and decodes its response.
    func run(command:Mongo.Hello) async throws -> Mongo.Hello.Response
    {
        return try Mongo.Hello.decode(message: try await self.run(
            command: command,
            against: .admin))
    }
    /// Runs a ``Mongo/EndSessions`` command, and decodes its response.
    func run(command:Mongo.EndSessions) async throws
    {
        return try Mongo.EndSessions.decode(message: try await self.run(
            command: command,
            against: .admin))
    }
}
extension Mongo.Connection
{
    /// Encodes the given command to a document, sends it over this connection and
    /// awaits its response.
    @inlinable public
    func run(command:__owned some MongoCommand, against database:Mongo.Database,
        labels:Mongo.TransactionLabels? = nil) async throws -> MongoWire.Message<ByteBufferView>
    {
        //  this is `@inlinable` because we want ``MongoCommand.encode(database:labels:)``
        //  to be inlined
        try await self.send(command: command.encode(database: database, labels: labels))
    }

    /// Sends a command document over this connection and awaits its response.
    public
    func send(command:__owned BSON.Fields) async throws -> MongoWire.Message<ByteBufferView>
    {
        return try await withCheckedThrowingContinuation
        {
            (continuation:CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>) in

            self.channel.writeAndFlush((command, continuation), promise: nil)
        }
    }
}
