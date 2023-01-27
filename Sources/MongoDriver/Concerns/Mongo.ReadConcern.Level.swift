import BSONSchema

extension Mongo.ReadConcern
{
    /// Models the same options as ``ReadLevel``, plus the ``snapshot`` option.
    /// The snapshot level can be used with transactions and snapshot sessions.
    @frozen public
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
