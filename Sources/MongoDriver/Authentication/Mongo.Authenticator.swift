import SCRAM
import SHA2

extension Mongo
{
    struct Authenticator:Sendable
    {
        let credentials:Credentials?
        private
        let cache:Cache

        init(credentials:Credentials?)
        {
            self.credentials = credentials
            self.cache = .init()
        }
    }
}
extension Mongo.Authenticator
{
    /// Establishes a connection, performing authentication if possible.
    /// If establishment fails, the connection’s TCP channel will *not*
    /// be closed.
    func establish(_ connection:Mongo.ConnectionAllocation,
        client:Mongo.Hello.ClientMetadata,
        by deadline:Mongo.ConnectionDeadline) async -> Result<Void, any Error>
    {
        let user:Mongo.Namespaced<String>?
        // if we don’t have an explicit authentication mode, ask the server
        // what it supports (for the current user).
        if  let credentials:Mongo.Credentials = self.credentials,
            case nil = credentials.authentication
        {
            user = credentials.user
        } 
        else
        {
            user = nil
        }

        let mechanisms:Set<Mongo.Authentication.SASL>?
        do
        {
            mechanisms = try await connection.run(
                hello: .init(client: client, user: user),
                by: deadline)
        }
        catch let error
        {
            return .failure(error)
        }

        if let credentials:Mongo.Credentials
        {
            do
            {
                try await self.authenticate(connection, credentials: credentials,
                    mechanisms: mechanisms,
                    by: deadline)
            }
            catch let error
            {
                return .failure(Mongo.AuthenticationError.init(error,
                    credentials: credentials))
            }
        }

        return .success(())
    }
}
extension Mongo.Authenticator
{
    private nonisolated
    func authenticate(_ connection:Mongo.ConnectionAllocation,
        credentials:Mongo.Credentials,
        mechanisms:Set<Mongo.Authentication.SASL>?,
        by deadline:Mongo.ConnectionDeadline) async throws
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
            try await self.authenticate(connection, sasl: .sha256,
                database: credentials.database,
                username: credentials.username,
                password: credentials.password,
                by: deadline)
        
        case .sha1:
            // note: we need to hash the password per
            // https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst#scram-sha-1
            throw Mongo.AuthenticationUnsupportedError.init(.sasl(.sha1))
        
        case let other:
            throw Mongo.AuthenticationUnsupportedError.init(.sasl(other))
        }
    } 
    private nonisolated
    func authenticate(_ connection:Mongo.ConnectionAllocation,
        sasl mechanism:Mongo.Authentication.SASL, 
        database:Mongo.Database, 
        username:String, 
        password:String,
        by deadline:Mongo.ConnectionDeadline) async throws 
    {
        let start:SCRAM.Start = .init(username: username)
        let first:Mongo.SASLResponse = try await connection.run(
            saslStart: .init(mechanism: mechanism, scram: start),
            against: database,
            by: deadline)
        
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

        let client:SCRAM.ClientResponse<SHA256> = try await self.cache.sha256(
            challenge: challenge,
            password: password,
            received: first.message,
            sent: start)
        let second:Mongo.SASLResponse = try await connection.run(
            saslContinue: first.command(message: client.message),
            against: database,
            by: deadline)
        
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
        
        let third:Mongo.SASLResponse = try await connection.run(
            saslContinue: second.command(message: .init("")),
            against: database,
            by: deadline)
        
        guard third.done
        else 
        {
            throw Mongo.SASLConversationError.init()
        }
    }
}
