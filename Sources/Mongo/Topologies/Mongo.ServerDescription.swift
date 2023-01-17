import MongoMonitoring

extension Mongo
{
    @frozen public
    enum ServerDescription<Metadata, Pool> where Pool:AnyObject & MongoMonitoringDelegate
    {
        case monitoring(Metadata, Pool)
        case errored(any Error)
        case queued
    }
}
extension Mongo.ServerDescription:Sendable where Metadata:Sendable, Pool:Sendable
{
}
extension Mongo.ServerDescription
{
    @inlinable public
    var metadata:Metadata?
    {
        if case .monitoring(let metadata, _) = self
        {
            return metadata
        }
        else
        {
            return nil
        }
    }
    @inlinable public
    var pool:Pool?
    {
        if case .monitoring(_, let pool) = self
        {
            return pool
        }
        else
        {
            return nil
        }
    }
    /// Returns the stored error, if this descriptor currently has one.
    @inlinable public
    var error:(any Error)?
    {
        if case .errored(let error) = self
        {
            return error
        }
        else
        {
            return nil
        }
    }
}
extension Mongo.ServerDescription
{
    @inlinable public mutating
    func update(with metadata:Metadata, pool:Pool)
    {
        self = .monitoring(metadata, pool)
    }
    /// Places this descriptor in an ``case errored(_:)`` or ``case queued``
    /// state. If `status` is [`nil`]() and the descriptor is already in
    /// an errored state, the descriptor will remain in that state, and the
    /// stored error will not be overwritten.
    @inlinable public mutating
    func clear(status:(any Error)?)
    {
        // only overwrite an existing error if we have a new one
        switch (status, self)
        {
        case (let error?, _):
            self = .errored(error)
        case (nil, .monitoring):
            self = .queued
        case (nil, _):
            break
        }
    }
}

extension Optional
{
    /// Sends a termination signal to the monitoring thread for this
    /// channel if non-[`nil`](), and sets this optional to [`nil`]()
    /// afterwards, preventing further use of the state descriptor.
    /// The optional will always be [`nil`]() after calling this method.
    @inlinable public mutating
    func remove<Member, Pool>()
        where Wrapped == Mongo.ServerDescription<Member, Pool>
    {
        self?.pool?.stopMonitoring()
        self = nil
    }
}
