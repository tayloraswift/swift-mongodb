import MongoDB

func ExampleConnectionStrings()
{
    let _ = MongoDB.SRV / ["example.com"]

    let _ = MongoDB.SRV / ["example.com": 53]

    let _ = MongoDB.SRV / ["example.com": 53] /?
    {
        $0.executors = nil
    }

    let _ = MongoDB.SRV / ("root", password: "password") * ["example.com": 53] /?
    {
        $0.executors = nil
    }

    let _ = MongoDB / ["mongo-0"]

    let _ = MongoDB / ["mongo-0": 27017]

    let _ = MongoDB / ["mongo-0": 27017] /?
    {
        $0.authentication = nil
    }

    let _ = MongoDB / ["mongo-0": nil, "mongo-1": 27017]

    let _ = MongoDB / ("root", "80085") * ["mongo-0", "mongo-1"]

    let _ = MongoDB / (username: "root", "80085") * ["mongo-0": nil, "mongo-1": 27017]

    let _ = MongoDB / (username: "root", "80085") * ["mongo-0", "mongo-1"] / .admin

    let _ = MongoDB / ("root", "80085") * ["mongo-0"] /?
    {
        $0.authentication = .sasl(.sha256)
    }

    let _ = MongoDB / ("root", "80085") * ["mongo-0", "mongo-1"] /?
    {
        $0.authentication = .sasl(.sha256)
    }

    let _ = MongoDB / ("root", "80085") * ["mongo-0": nil, "mongo-1": 27017] / .admin /?
    {
        $0.topology = .replicated(set: "test-set")
        $0.tls = .enabled

        $0.connectionTimeout = .milliseconds(2000)
    }
}
