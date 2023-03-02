extension Mongo
{
    enum Observers
    {
        case none
        case one(CheckedContinuation<Void, Never>)
        case many([CheckedContinuation<Void, Never>])
    }
}
extension Mongo.Observers
{
    mutating
    func append(_ observer:CheckedContinuation<Void, Never>)
    {
        switch self
        {
        case .none:
            self = .one(observer)
        case .one(let first):
            self = .many([first, observer])
        case .many(var list):
            self = .none
            list.append(observer)
            self = .many(list)
        }
    }
    mutating
    func resume()
    {
        defer
        {
            self = .none
        }
        switch self
        {
        case .none:
            return
        case .one(let observer):
            observer.resume()
        case .many(let observers):
            for observer:CheckedContinuation<Void, Never> in observers
            {
                observer.resume()
            }
        }
    }
}
