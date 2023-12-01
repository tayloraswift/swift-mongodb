import MongoDriver

extension Mongo
{
    @frozen public
    enum SingleOutputError:Equatable, Sendable, Error
    {
        case cursor(CursorIdentifier)
        case count(Int)
    }
}
extension Mongo.SingleOutputError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .cursor(let cursor):
            "single-output command returned additional batches (with cursor '\(cursor)')"
        case .count(let count):
            "single-output command returned \(count) elements"
        }
    }
}
