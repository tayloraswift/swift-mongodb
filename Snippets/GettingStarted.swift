import MongoDB
import NIOCore
import NIOPosix

let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

let bootstrap:Mongo.DriverBootstrap = MongoDB / ["mongo-0", "mongo-1"] /?
{
    $0.executors = .shared(executors)
    $0.appname = "example app"
}

let configuration:Mongo.ReplicaSetConfiguration = try await bootstrap.withSessionPool
{
    try await $0.run(
        command: Mongo.ReplicaSetGetConfiguration.init(),
        against: .admin)
}

print(configuration)
