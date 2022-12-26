import MongoTopology

extension Mongo
{
    struct SessionMediumRequests
    {
        private
        var requests:[UInt: SessionMediumRequest]
        private
        var counter:UInt

        init()
        {
            self.requests = [:]
            self.counter = 0
        }
    }
}
extension Mongo.SessionMediumRequests
{
    var isEmpty:Bool
    {
        self.requests.isEmpty
    }

    mutating
    func open() -> UInt
    {
        self.counter += 1
        return self.counter
    }
    mutating
    func submit(_ id:UInt, request:Mongo.SessionMediumRequest)
    {
        self.requests.updateValue(request, forKey: id)
    }
    mutating
    func fail(_ id:UInt, errored hosts:[MongoTopology.Host: any Error])
    {
        self.requests[id].fail(errored: hosts)
    }
    mutating
    func fulfill(with medium:Mongo.SessionMedium,
        where predicate:(Mongo.SessionMediumSelector) -> Bool)
    {
        for key:UInt in self.requests.keys
        {
            self.requests[key].fulfill(with: medium, where: predicate)
        }
    }
}
