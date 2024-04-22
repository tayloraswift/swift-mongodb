import MongoConfiguration
import MongoDriver
import NIOPosix
import Testing_

func TestAuthentication(_ tests:TestGroup,
    executors:MultiThreadedEventLoopGroup,
    seedlist:Mongo.Seedlist,
    username:String,
    password:String) async
{
    await (tests / "authentication" / "defaulted")?.do
    {
        let bootstrap:Mongo.DriverBootstrap = mongodb / (username, password) * seedlist /?
        {
            $0.executors = .shared(executors)
        }
        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
    }

    await (tests / "authentication" / "scram-sha256")?.do
    {
        let bootstrap:Mongo.DriverBootstrap = mongodb / (username, password) * seedlist /?
        {
            $0.authentication = .sasl(.sha256)
            $0.executors = .shared(executors)
        }
        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
    }

    if  let tests:TestGroup = tests / "authentication-unsupported"
    {
        let bootstrap:Mongo.DriverBootstrap = mongodb / (username, password) * seedlist /?
        {
            $0.connectionTimeout = .milliseconds(500)
            $0.authentication = .x509
            $0.executors = .shared(executors)
        }
        await tests.do(catching: Mongo.ConnectionPoolDrainedError.init(
            because: Mongo.AuthenticationError.init(
                    Mongo.AuthenticationUnsupportedError.init(.x509),
                credentials: bootstrap.credentials!),
            host: seedlist[0]))
        {
            try await bootstrap.withSessionPool
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
    }

    if  let tests:TestGroup = tests / "authentication-wrong-password"
    {
        let bootstrap:Mongo.DriverBootstrap = mongodb / (username, "1234") * seedlist /?
        {
            $0.connectionTimeout = .milliseconds(500)
            $0.authentication = .sasl(.sha256)
            $0.executors = .shared(executors)
        }
        await tests.do(catching: Mongo.ConnectionPoolDrainedError.init(
            because: Mongo.AuthenticationError.init(Mongo.ServerError.init(18,
                    message: "Authentication failed."),
                credentials: bootstrap.credentials!),
            host: seedlist[0]))
        {
            try await bootstrap.withSessionPool
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
    }
}
