extension Mongo
{
    @frozen public
    enum SeedingMethod:Sendable
    {
        case direct(Seedlist)
        case dns(Host)
    }
}
