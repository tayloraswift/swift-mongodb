import MongoChannel
import MongoDriver
import NIOPosix
import Testing

func TestAuthentication(_ tests:inout Tests,
    credentials:Mongo.Credentials,
    standalone:Mongo.Host,
    on executor:MultiThreadedEventLoopGroup) async
{
    await tests.group("authentication")
    {
        await $0.test(with: DriverEnvironment.init(name: "defaulted",
            credentials: .init(authentication: nil,
                username: credentials.username,
                password: credentials.password),
            executor: executor))
        {
            try await $1.withSessionPool(seedlist: [standalone])
            {
                try await $0.withSession
                {
                    _ in
                }
            }
        }

        await $0.test(with: DriverEnvironment.init(name: "scram-sha256",
            credentials: credentials,
            executor: executor))
        {
            try await $1.withSessionPool(seedlist: [standalone])
            {
                try await $0.withSession
                {
                    _ in
                }
            }
        }
    }

    await tests.test(with: DriverEnvironment.init(name: "authentication-unsupported",
        credentials: .init(authentication: .x509,
            username: credentials.username,
            password: credentials.password),
        executor: executor))
    {
        (tests:inout Tests, bootstrap:Mongo.DriverBootstrap) in

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

    await tests.test(with: DriverEnvironment.init(name: "authentication-wrong-password",
        credentials: .init(authentication: .sasl(.sha256),
            username: "root",
            password: "1234"),
        executor: executor))
    {
        (tests:inout Tests, bootstrap:Mongo.DriverBootstrap) in

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
