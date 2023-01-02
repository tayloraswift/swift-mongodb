extension MongoTopology
{
    /// A reason why a server was deemed *undesirable*.
    ///
    /// Desirability is determined by read mode and server type.
    /// Some server types, like `mongos` routers, are always
    /// desirable.
    @frozen public
    enum Undesirable:Hashable, Sendable
    {
        case standalone
        case primary
        case secondary
        case arbiter
        case other
        case ghost
    }
}
