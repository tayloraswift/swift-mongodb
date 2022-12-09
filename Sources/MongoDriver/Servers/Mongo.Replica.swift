extension Mongo
{
    enum Replica
    {
        case primary(Master)
        case secondary(Slave)
        case arbiter(Slave)
        case other(Slave)
    }
}
