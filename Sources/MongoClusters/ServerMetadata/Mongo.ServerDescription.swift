extension Mongo
{
    @frozen public
    enum ServerDescription<Metadata, Owner> where Owner:AnyObject
    {
        case connected(Metadata, Owner)
        case errored(any Error)
        case queued
    }
}
extension Mongo.ServerDescription:Sendable where Metadata:Sendable, Owner:Sendable
{
}
extension Mongo.ServerDescription
{
    @inlinable public
    var metadata:Metadata?
    {
        if case .connected(let metadata, _) = self
        {
            metadata
        }
        else
        {
            nil
        }
    }
    @inlinable public
    var owner:Owner?
    {
        if case .connected(_, let owner) = self
        {
            owner
        }
        else
        {
            nil
        }
    }
    /// Returns the stored error, if this descriptor currently has one.
    @inlinable public
    var error:(any Error)?
    {
        if case .errored(let error) = self
        {
            error
        }
        else
        {
            nil
        }
    }
}
extension Mongo.ServerDescription
{
    mutating
    func assign(metadata:__owned Metadata, owner:__owned Owner?) -> Mongo.TopologyUpdateResult
    {
        if  let owner:Owner
        {
            self = .connected(metadata, owner)
            return .accepted
        }
        switch self
        {
        case .connected(_, let owner):
            self = .connected(metadata, owner)
            return .accepted

        case .errored, .queued:
            return .dropped
        }
    }

    /// Places this descriptor in an ``case errored(_:)`` or ``case queued``
    /// state. If `status` is nil and the descriptor is already in
    /// an errored state, the descriptor will remain in that state, and the
    /// stored error will not be overwritten.
    mutating
    func assign(error status:(any Error)?) -> Mongo.TopologyUpdateResult
    {
        // only overwrite an existing error if we have a new one
        switch (status, self)
        {
        case (let error?, _):
            self = .errored(error)
        case (nil, .connected):
            self = .queued
        case (nil, _):
            break
        }
        return .accepted
    }
}
