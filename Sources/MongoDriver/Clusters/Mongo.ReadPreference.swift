import BSONEncoding
import Durations
import MongoTopology

extension Mongo
{
    @frozen public
    enum ReadPreference:Equatable, Sendable
    {
        case secondary          (MongoTopology.Eligibility, hedge:Hedging? = nil)
        case secondaryPreferred (MongoTopology.Eligibility, hedge:Hedging? = nil)
        case nearest            (MongoTopology.Eligibility, hedge:Hedging? = nil)
        case primaryPreferred   (MongoTopology.Eligibility, hedge:Hedging? = nil)
        case primary
    }
}
extension Mongo.ReadPreference
{
    @inlinable public static
    var secondary:Self
    {
        .secondary(.init())
    }
    @inlinable public static
    var secondaryPreferred:Self
    {
        .secondaryPreferred(.init())
    }
    @inlinable public static
    var nearest:Self
    {
        .nearest(.init())
    }
    @inlinable public static
    var primaryPreferred:Self
    {
        .primaryPreferred(.init())
    }
}
extension Mongo.ReadPreference
{
    @inlinable public static
    func secondary(
        maxStaleness seconds:Seconds? = nil,
        tagSets:[MongoTopology.TagSet]? = nil,
        hedge hedging:Hedging? = nil) -> Self
    {
        .secondary(.init(maxStaleness: seconds, tagSets: tagSets),
            hedge: hedging)
    }
    @inlinable public static
    func secondaryPreferred(
        maxStaleness seconds:Seconds? = nil,
        tagSets:[MongoTopology.TagSet]? = nil,
        hedge hedging:Hedging? = nil) -> Self
    {
        .secondaryPreferred(.init(maxStaleness: seconds, tagSets: tagSets),
            hedge: hedging)
    }
    @inlinable public static
    func nearest(
        maxStaleness seconds:Seconds? = nil,
        tagSets:[MongoTopology.TagSet]? = nil,
        hedge hedging:Hedging? = nil) -> Self
    {
        .nearest(.init(maxStaleness: seconds, tagSets: tagSets),
            hedge: hedging)
    }
    @inlinable public static
    func primaryPreferred(
        maxStaleness seconds:Seconds? = nil,
        tagSets:[MongoTopology.TagSet]? = nil,
        hedge hedging:Hedging? = nil) -> Self
    {
        .primaryPreferred(.init(maxStaleness: seconds, tagSets: tagSets),
            hedge: hedging)
    }
}
extension Mongo.ReadPreference
{
    var mode:MongoTopology.ReadMode
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
    var eligibility:MongoTopology.Eligibility?
    {
        switch self
        {
        case    .secondary          (let eligibility, hedge: _),
                .secondaryPreferred (let eligibility, hedge: _),
                .nearest            (let eligibility, hedge: _),
                .primaryPreferred   (let eligibility, hedge: _):
            return eligibility
        case _:
            return nil
        }
    }
    var maxStaleness:Seconds?
    {
        self.eligibility?.maxStaleness
    }
    var tagSets:[MongoTopology.TagSet]?
    {
        self.eligibility?.tagSets
    }
    var hedge:Hedging?
    {
        switch self
        {
        case    .secondary          (_, hedge: let hedging),
                .secondaryPreferred (_, hedge: let hedging),
                .nearest            (_, hedge: let hedging),
                .primaryPreferred   (_, hedge: let hedging):
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
extension Mongo.ReadPreference
{
    func diagnose(unsuitable servers:MongoTopology.Servers) -> MongoTopology.Diagnostics
    {
        let diagnostics:MongoTopology.Diagnostics
        switch self
        {
        case    .primary:
            diagnostics = servers.diagnose(mode: .primary)
        case    .secondary          (let eligibility, hedge: _),
                .secondaryPreferred (let eligibility, hedge: _),
                .nearest            (let eligibility, hedge: _),
                .primaryPreferred   (let eligibility, hedge: _):
            diagnostics = servers.diagnose(mode: self.mode, where: eligibility)
        }
        return diagnostics
    }
}
