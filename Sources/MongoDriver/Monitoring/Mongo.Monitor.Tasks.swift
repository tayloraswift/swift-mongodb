extension Mongo.Monitor
{
    /// Keeps a count of running monitoring tasks, regulates when
    /// new monitoring tasks can be started, and allows the consumer
    /// of this type to wait for all monitoring tasks to halt.
    struct Tasks
    {
        private(set)
        var count:Int
        var promise:CheckedContinuation<Void, Never>?

        init()
        {
            self.count = 0
            self.promise = nil
        }
    }
}
extension Mongo.Monitor.Tasks
{
    mutating
    func retain(_ operation:@Sendable @escaping () async -> ()) -> Task<Void, Never>?
    {
        if case nil = self.promise
        {
            self.count += 1
            return .init(operation: operation)
        }
        else
        {
            return nil
        }
    }
    mutating
    func release()
    {
        self.count -= 1

        if  self.count == 0, 
            let promise:CheckedContinuation<Void, Never> = self.promise
        {
            promise.resume()
            self.promise = nil
        }
    }
}
