import BSON
import UnixTime

extension Mongo
{
    @frozen public
    enum ReadPreference:Equatable, Sendable
    {
        case secondary          (Eligibility, hedge:Hedging? = nil)
        case secondaryPreferred (Eligibility, hedge:Hedging? = nil)
        case nearest            (Eligibility, hedge:Hedging? = nil)
        case primaryPreferred   (Eligibility, hedge:Hedging? = nil)
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
        tagSets:[TagSet]? = nil,
        hedge hedging:Hedging? = nil) -> Self
    {
        .secondary(.init(maxStaleness: seconds, tagSets: tagSets),
            hedge: hedging)
    }
    @inlinable public static
    func secondaryPreferred(
        maxStaleness seconds:Seconds? = nil,
        tagSets:[TagSet]? = nil,
        hedge hedging:Hedging? = nil) -> Self
    {
        .secondaryPreferred(.init(maxStaleness: seconds, tagSets: tagSets),
            hedge: hedging)
    }
    @inlinable public static
    func nearest(
        maxStaleness seconds:Seconds? = nil,
        tagSets:[TagSet]? = nil,
        hedge hedging:Hedging? = nil) -> Self
    {
        .nearest(.init(maxStaleness: seconds, tagSets: tagSets),
            hedge: hedging)
    }
    @inlinable public static
    func primaryPreferred(
        maxStaleness seconds:Seconds? = nil,
        tagSets:[TagSet]? = nil,
        hedge hedging:Hedging? = nil) -> Self
    {
        .primaryPreferred(.init(maxStaleness: seconds, tagSets: tagSets),
            hedge: hedging)
    }
}
extension Mongo.ReadPreference
{
    var mode:Mode
    {
        switch self
        {
        case .secondary:            .secondary
        case .secondaryPreferred:   .secondaryPreferred
        case .nearest:              .nearest
        case .primaryPreferred:     .primaryPreferred
        case .primary:              .primary
        }
    }
    var eligibility:Eligibility?
    {
        switch self
        {
        case    .secondary          (let eligibility, hedge: _),
                .secondaryPreferred (let eligibility, hedge: _),
                .nearest            (let eligibility, hedge: _),
                .primaryPreferred   (let eligibility, hedge: _):
            eligibility
        case _:
            nil
        }
    }
    var maxStaleness:Seconds?
    {
        self.eligibility?.maxStaleness
    }
    var tagSets:[TagSet]?
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
            hedging
        case _:
            nil
        }
    }
}
extension Mongo.ReadPreference:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson["mode"] = self.mode
        bson["maxStalenessSeconds"] = self.maxStaleness
        bson["tag_sets"] = self.tagSets
        bson["hedge"] = self.hedge
    }
}
extension Mongo.ReadPreference
{
    func diagnose(servers:Mongo.ServerTable) -> Mongo.SelectionDiagnostics
    {
        switch servers
        {
        case .none(let unreachable):
            return .init(unreachable: unreachable)

        case .single(let standalone):
            switch self
            {
            case .primary, .primaryPreferred, .nearest, .secondaryPreferred:
                return .init()

            case .secondary:
                return .init(undesirable: [standalone.server.host: .standalone])
            }

        case .sharded(let routers):
            return .init(unreachable: routers.unreachables)

        case .replicated(let members):
            let undesirable:[Mongo.Host: Mongo.Undesirable]
            let unsuitable:[Mongo.Host: Mongo.Unsuitable]

            switch self
            {
            case    .primary:
                undesirable = members.candidates.secondaries.reduce(into: members.undesirables)
                {
                    $0[$1.host] = .secondary
                }
                unsuitable = [:]

            case    .primaryPreferred   (let eligibility, hedge: _),
                    .secondaryPreferred (let eligibility, hedge: _):
                undesirable = members.undesirables
                unsuitable = eligibility.diagnose(unsuitable: members.candidates.secondaries)

            case    .secondary          (let eligibility, hedge: _):
                var undesirables:[Mongo.Host: Mongo.Undesirable] = members.undesirables
                if  let primary:Mongo.Host = members.candidates.primary?.host
                {
                    undesirables[primary] = .primary
                }
                undesirable = undesirables
                unsuitable = eligibility.diagnose(unsuitable: members.candidates.secondaries)

            case    .nearest            (let eligibility, hedge: _):
                undesirable = members.undesirables
                unsuitable = eligibility.diagnose(unsuitable: members.candidates.replicas)
            }

            return .init(unreachable: members.unreachables,
                undesirable: undesirable,
                unsuitable: unsuitable)
        }
    }
}
