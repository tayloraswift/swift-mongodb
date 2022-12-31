import BSONEncoding
import Durations
import MongoTopology

extension Mongo.ReadPreference
{
    @available(*, deprecated, renamed: "primary")
    static
    let master:Self = .primary
    @available(*, deprecated, renamed: "nearest")
    static
    let any:Self = .nearest
}
extension Mongo
{
    @available(*, deprecated, renamed: "MongoTopology.ReadPreference")
    public
    typealias SessionMediumSelector = ReadPreference
}

extension Mongo.ReadPreference
{
    @frozen public
    enum Hedging
    {
        case enabled
        case disabled
    }
}
extension Mongo.ReadPreference.Hedging:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["enabled"] = self == .enabled
    }
}
extension Mongo
{
    @frozen public
    enum ReadPreference
    {
        case secondary          (maxStaleness:Seconds? = nil, tagSets:[BSON.Fields]? = nil, hedge:Hedging? = nil)
        case secondaryPreferred (maxStaleness:Seconds? = nil, tagSets:[BSON.Fields]? = nil, hedge:Hedging? = nil)
        case nearest            (maxStaleness:Seconds? = nil, tagSets:[BSON.Fields]? = nil, hedge:Hedging? = nil)
        case primaryPreferred   (maxStaleness:Seconds? = nil, tagSets:[BSON.Fields]? = nil, hedge:Hedging? = nil)
        case primary
    }
}
extension Mongo.ReadPreference
{
    @inlinable public static
    var secondary:Self
    {
        .secondary()
    }
    @inlinable public static
    var secondaryPreferred:Self
    {
        .secondaryPreferred()
    }
    @inlinable public static
    var nearest:Self
    {
        .nearest()
    }
    @inlinable public static
    var primaryPreferred:Self
    {
        .primaryPreferred()
    }
}
extension Mongo.ReadPreference
{
    var mode:MongoTopology.ReadMode?
    {
        switch self
        {
        case .secondary:            return .secondary
        case .secondaryPreferred:   return .secondaryPreferred
        case .nearest:              return .nearest
        case .primaryPreferred:     return .primaryPreferred
        case .primary:              return .primary
        }
    }
    var maxStaleness:Seconds?
    {
        switch self
        {
        case .secondary          (maxStaleness: let seconds, tagSets: _, hedge: _):
            return seconds
        case .secondaryPreferred (maxStaleness: let seconds, tagSets: _, hedge: _):
            return seconds
        case .nearest            (maxStaleness: let seconds, tagSets: _, hedge: _):
            return seconds
        case .primaryPreferred   (maxStaleness: let seconds, tagSets: _, hedge: _):
            return seconds
        case _:
            return nil
        }
    }
    var tagSets:[BSON.Fields]?
    {
        switch self
        {
        case .secondary          (maxStaleness: _, tagSets: let list, hedge: _):
            return list
        case .secondaryPreferred (maxStaleness: _, tagSets: let list, hedge: _):
            return list
        case .nearest            (maxStaleness: _, tagSets: let list, hedge: _):
            return list
        case .primaryPreferred   (maxStaleness: _, tagSets: let list, hedge: _):
            return list
        case _:
            return nil
        }
    }
    var hedge:Hedging?
    {
        switch self
        {
        case .secondary          (maxStaleness: _, tagSets: _, hedge: let hedging):
            return hedging
        case .secondaryPreferred (maxStaleness: _, tagSets: _, hedge: let hedging):
            return hedging
        case .nearest            (maxStaleness: _, tagSets: _, hedge: let hedging):
            return hedging
        case .primaryPreferred   (maxStaleness: _, tagSets: _, hedge: let hedging):
            return hedging
        case _:
            return nil
        }
    }
}
extension Mongo.ReadPreference:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["mode"] = self.mode
        bson["maxStalenessSeconds"] = self.maxStaleness
        bson["tag_sets"] = self.tagSets
        bson["hedge"] = self.hedge
    }
}
