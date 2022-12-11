import NIOPosix
import MongoDriver
import Testing

@main 
enum Main:AsynchronousTests
{
    static
    func run(tests:inout Tests) async
    {
        let host:Mongo.Host = .init(name: "mongodb", port: 27017)
        let group:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        
        await tests.group("authentication")
        {
            // since we do not perform any operations, this should succeed
            // await $0.do(name: "none")
            // {
            //     _ in 
            //     let _:Mongo.SessionPool = .init(
            //         settings: .init(timeout: .seconds(10)),
            //         group: group,
            //         seeds:
            //         [
            //             host,
            //         ])
            // }

            await $0.do(name: "defaulted")
            {
                _ in 
                let pool:Mongo.SessionPool = .init(
                    credentials: .init(authentication: nil,
                        username: "root",
                        password: "password"),
                    settings: .init(timeout: .seconds(10)),
                    group: group,
                    seeds:
                    [
                        host,
                    ])
                let _:Mongo.MutableSession = try await .init(on: pool)
            }

            let x509:Mongo.Credentials = .init(authentication: .x509,
                username: "root",
                password: "password")
            await $0.do(name: "unsupported", 
                expecting: Mongo.ConnectionErrors.init(selector: .master, 
                    errors:
                    [
                        (
                            host, 
                            Mongo.AuthenticationError.init(
                                Mongo.AuthenticationUnsupportedError.init(.x509),
                            credentials: x509))
                    ]))
            {
                _ in
                let pool:Mongo.SessionPool = .init(credentials: x509,
                    settings: .init(timeout: .seconds(10)),
                    group: group,
                    seeds:
                    [
                        host,
                    ])
                let _:Mongo.MutableSession = try await .init(on: pool)
            }

            let sha256:Mongo.Credentials = .init(authentication: .sasl(.sha256),
                username: "root",
                password: "1234")
            await $0.do(name: "wrong-password",
                expecting: Mongo.ConnectionErrors.init(selector: .master, 
                    errors:
                    [
                        (
                            host, 
                            Mongo.AuthenticationError.init(
                                Mongo.ServerError.init(message: "Authentication failed."),
                            credentials: sha256))
                    ]))
            {
                _ in
                let pool:Mongo.SessionPool = .init(credentials: sha256,
                    settings: .init(timeout: .seconds(10)),
                    group: group,
                    seeds:
                    [
                        host,
                    ])
                let _:Mongo.MutableSession = try await .init(on: pool)
            }

            await $0.do(name: "scram-sha256")
            {
                _ in
                let pool:Mongo.SessionPool = .init(
                    credentials: .init(authentication: .sasl(.sha256),
                        username: "root",
                        password: "password"),
                    settings: .init(timeout: .seconds(10)),
                    group: group,
                    seeds:
                    [
                        host
                    ])
                let _:Mongo.MutableSession = try await .init(on: pool)
            }
        }

        await tests.do(name: "shutdown")
        {
            _ in

            do
            {
                let pool:Mongo.SessionPool = .init(
                    credentials: .init(authentication: .sasl(.sha256),
                        username: "root",
                        password: "password"),
                    settings: .init(timeout: .seconds(10)),
                    group: group,
                    seeds:
                    [
                        host
                    ])
                // need to generate at least one session
                let _:Mongo.MutableSession = try await .init(on: pool)
            }

            try await Task.sleep(for: .milliseconds(100))
        }
    }
}
