import MongoChannel
import MongoDriver
import NIOPosix
import Testing

func TestAuthentication(_ tests:TestGroup,
    standalone:Mongo.Host,
    username:String,
    password:String,
    on executor:MultiThreadedEventLoopGroup) async
{
    await (tests / "authentication" / "defaulted").do
    {
        let bootstrap:Mongo.DriverBootstrap = .init(credentials: .init(
                authentication: nil,
                username: username,
                password: password),
            executor: executor)
        try await bootstrap.withSessionPool(seedlist: [standalone])
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
    }

    await (tests / "authentication" / "scram-sha256").do
    {
        let bootstrap:Mongo.DriverBootstrap = .init(credentials: .init(
                authentication: .sasl(.sha256),
                username: username,
                password: password),
            executor: executor)
        try await bootstrap.withSessionPool(seedlist: [standalone])
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
    }

    do
    {
        let tests:TestGroup = tests / "authentication-unsupported"

        let bootstrap:Mongo.DriverBootstrap = .init(credentials: .init(
                authentication: .x509,
                username: username,
                password: password),
            executor: executor)

        await tests.do(catching: Mongo.ClusterError<Mongo.LogicalSessionsError>.init(
            diagnostics: .init(unreachable:
            [
                standalone: .errored(Mongo.AuthenticationError.init(
                        Mongo.AuthenticationUnsupportedError.init(.x509),
                    credentials: bootstrap.credentials!))
            ]),
            failure: .init()))
        {
            try await bootstrap.withSessionPool(seedlist: [standalone],
                timeout: .init(milliseconds: 500))
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
    }

    do
    {
        let tests:TestGroup = tests / "authentication-wrong-password"

        let bootstrap:Mongo.DriverBootstrap = .init(credentials: .init(
                authentication: .sasl(.sha256),
                username: "root",
                password: "1234"),
            executor: executor)

        await tests.do(catching: Mongo.ClusterError<Mongo.LogicalSessionsError>.init(
            diagnostics: .init(unreachable:
            [
                standalone: .errored(Mongo.AuthenticationError.init(
                        Mongo.ServerError.init(18,
                            message: "Authentication failed."),
                    credentials: bootstrap.credentials!))
            ]),
            failure: .init()))
        {
            try await bootstrap.withSessionPool(seedlist: [standalone],
                timeout: .init(milliseconds: 500))
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
    }
}
