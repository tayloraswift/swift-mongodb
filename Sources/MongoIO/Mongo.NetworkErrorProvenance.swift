extension Mongo
{
    @frozen public
    enum NetworkErrorProvenance:Equatable, Sendable
    {
        case crosscancellation
    }
}
