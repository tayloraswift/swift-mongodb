import BSONSchema

extension Mongo.ReadConcern
{
    enum Level:String, Hashable, Sendable
    {
        case local
        case available
        case majority
        case linearizable
        case snapshot
    }
}
extension Mongo.ReadConcern.Level
{
    init(_ level:Mongo.ReadLevel)
    {
        switch level
        {
        case .local:        self = .local
        case .available:    self = .available
        case .majority:     self = .majority
        case .linearizable: self = .linearizable
        }
    }
}
extension Mongo.ReadConcern.Level:BSONScheme
{
}
