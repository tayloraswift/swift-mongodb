extension Mongo.ReplicaSetConfiguration
{
    @frozen public
    enum Rights:Equatable, Sendable
    {
        case resident(Resident)
        case citizen(Citizen)
    }
}
extension Mongo.ReplicaSetConfiguration.Rights
{
    /// Configures a citizen with a priority of [`1.0`]().
    @inlinable public static
    var citizen:Self
    {
        .citizen(.init())
    }
    /// Configures a resident with default settings.
    /// (Builds indexes, and is not delayed.)
    @inlinable public static
    var resident:Self
    {
        .resident(.init())
    }

    @inlinable public
    init(priority:Double)
    {
        if let citizen:Mongo.ReplicaSetConfiguration.Citizen = .init(priority: priority)
        {
            self = .citizen(citizen)
        }
        else
        {
            self = .resident(.init())
        }
    }
}
