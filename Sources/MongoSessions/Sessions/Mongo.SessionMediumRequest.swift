extension Mongo
{
    struct SessionMediumRequest
    {
        let selector:SessionMediumSelector
        let promise:CheckedContinuation<SessionMedium, any Error>

        init(promise:CheckedContinuation<SessionMedium, any Error>,
            of selector:SessionMediumSelector)
        {
            self.selector = selector
            self.promise = promise
        }
    }
}
extension Mongo.SessionMediumRequest?
{
    mutating
    func fail(errored hosts:[Mongo.Host: any Error])
    {
        if let request:Mongo.SessionMediumRequest = self
        {
            request.promise.resume(throwing: Mongo.SessionMediumError.init(
                selector: request.selector,
                errored: hosts))
            self = nil
        }
    }
    mutating
    func fulfill(with medium:Mongo.SessionMedium,
        where predicate:(Mongo.SessionMediumSelector) -> Bool)
    {
        if let request:Mongo.SessionMediumRequest = self, predicate(request.selector)
        {
            request.promise.resume(returning: medium)
            self = nil
        }
    }
}
