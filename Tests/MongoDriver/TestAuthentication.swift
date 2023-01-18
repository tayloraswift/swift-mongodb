import MongoChannel
import MongoDriver
import NIOPosix
import Testing

func TestAuthentication(_ tests:inout Tests,
    standalone:Mongo.Host,
    username:String,
    password:String,
    on executor:MultiThreadedEventLoopGroup) async
{
    await tests.group("authentication")
    {
        await $0.test(name: "defaulted")
        {
            _ in
            let bootstrap:Mongo.DriverBootstrap = .init(credentials: .init(
                    authentication: nil,
                    username: username,
                    password: password),
                executor: executor)
            try await bootstrap.withSessionPool(seedlist: [standalone])
            {
                try await $0.withSession
                {
                    _ in
                }
            }
        }

        await $0.test(name: "scram-sha256")
        {
            _ in
            let bootstrap:Mongo.DriverBootstrap = .init(credentials: .init(
                    authentication: .sasl(.sha256),
                    username: username,
                    password: password),
                executor: executor)
            try await bootstrap.withSessionPool(seedlist: [standalone])
            {
                try await $0.withSession
                {
                    _ in
                }
            }
        }
    }

    await tests.test(name: "authentication-unsupported")
    {
        (tests:inout Tests) in

        let bootstrap:Mongo.DriverBootstrap = .init(credentials: .init(
                authentication: .x509,
                username: username,
                password: password),
            executor: executor)

        await tests.test(name: "errors-equal",
            expecting: Mongo.ClusterError<Mongo.LogicalSessionsError>.init(
                diagnostics: .init(unreachable:
                [
                    standalone: .errored(Mongo.AuthenticationError.init(
                            Mongo.AuthenticationUnsupportedError.init(.x509),
                        credentials: bootstrap.credentials!))
                ]),
                failure: .init()))
        {
            _ in
            try await bootstrap.withSessionPool(seedlist: [standalone],
                timeout: .init(milliseconds: 500))
            {
                try await $0.withSession
                {
                    _ in
                }
            }
        }
    }

    await tests.test(name: "authentication-wrong-password")
    {
        (tests:inout Tests) in

        let bootstrap:Mongo.DriverBootstrap = .init(credentials: .init(
                authentication: .sasl(.sha256),
                username: "root",
                password: "1234"),
            executor: executor)

        await tests.test(name: "errors-equal",
            expecting: Mongo.ClusterError<Mongo.LogicalSessionsError>.init(
                diagnostics: .init(unreachable:
                [
                    standalone: .errored(Mongo.AuthenticationError.init(
                            Mongo.ServerError.init(
                                message: "Authentication failed.",
                                code: 18),
                        credentials: bootstrap.credentials!))
                ]),
                failure: .init()))
        {
            _ in
            try await bootstrap.withSessionPool(seedlist: [standalone],
                timeout: .init(milliseconds: 500))
            {
                try await $0.withSession
                {
                    _ in
                }
            }
        }
    }
}
