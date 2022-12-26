extension MongoTopology
{
    @frozen public
    enum Replica:Sendable
    {
        case primary(Master)
        case secondary(Slave)
        case arbiter(Slave)
        case other(Slave)
    }
}
