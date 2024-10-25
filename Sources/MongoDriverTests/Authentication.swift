import MongoConfiguration
import MongoDriver
import NIOPosix
import Testing

@Suite struct Authentication
{
    static var username:String { "root" }
    static var password:String { "80085" }

    let seedlist:Mongo.Seedlist

    init()
    {
        self.seedlist = .standalone
    }

    static var login:(String, String) { (Self.username, Self.password) }

    @Test
    func defaulted() async throws
    {
        let bootstrap:Mongo.DriverBootstrap = mongodb / Self.login * self.seedlist /?
        {
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
        }
        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
    }

    @Test
    func scramSHA256() async throws
    {
        let bootstrap:Mongo.DriverBootstrap = mongodb / Self.login * self.seedlist /?
        {
            $0.authentication = .sasl(.sha256)
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
        }
        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
    }

    @Test
    func unsupported() async throws
    {
        let bootstrap:Mongo.DriverBootstrap = mongodb / Self.login * self.seedlist /?
        {
            $0.connectionTimeout = .milliseconds(500)
            $0.authentication = .x509
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
        }
        await #expect(throws: Mongo.ConnectionPoolDrainedError.init(
            because: Mongo.AuthenticationError.init(
                    Mongo.AuthenticationUnsupportedError.init(.x509),
                credentials: bootstrap.credentials!),
            host: self.seedlist[0]))
        {
            try await bootstrap.withSessionPool
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
    }

    @Test
    func wrongPassword() async throws
    {
        let bootstrap:Mongo.DriverBootstrap =
            mongodb / (Self.username, "1234") * self.seedlist /?
        {
            $0.connectionTimeout = .milliseconds(500)
            $0.authentication = .sasl(.sha256)
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
        }
        await #expect(throws: Mongo.ConnectionPoolDrainedError.init(
            because: Mongo.AuthenticationError.init(Mongo.ServerError.init(18,
                    message: "Authentication failed."),
                credentials: bootstrap.credentials!),
            host: self.seedlist[0]))
        {
            try await bootstrap.withSessionPool
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
    }
}
