import Heartbeats
import MongoChannel

extension MongoConnection
{
    @frozen public
    enum State
    {
        case connected(MongoConnection<Metadata>)
        case errored(any Error)
        case queued
    }
}
extension MongoConnection.State:Sendable where Metadata:Sendable
{
}
extension MongoConnection.State
{
    /// Returns the stored connection, if this descriptor currently has any.
    @inlinable public
    var connection:MongoConnection<Metadata>?
    {
        if case .connected(let connection) = self
        {
            return connection
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

    /// Returns the stored metadata, if this descriptor currently has any.
    @available(*, deprecated, message: "use `connection?.metadata` instead")
    @inlinable public
    var metadata:Metadata?
    {
        self.connection?.metadata
    }
    /// Returns the stored channel, if this descriptor currently has one.
    @available(*, deprecated, message: "use `connection?.channel` instead")
    @inlinable public
    var channel:MongoChannel?
    {
        self.connection?.channel
    }
}
extension MongoConnection.State
{
    /// Updates the metadata for the stored channel.
    /// If this descriptor does not already have a channel, the
    /// `channel` argument will be stored in it.
    ///
    /// -   Parameters:
    ///     -   channel: A wrapped NIO channel. If this descriptor already has one,
    ///         the parameter must be identical to it.
    ///     -   metadata: The metadata to update.
    @inlinable public mutating
    func update(with connection:MongoConnection<Metadata>)
    {
        guard let original:MongoChannel = self.connection?.channel
        else
        {
            self = .connected(connection)
            return
        }
        if connection.channel === original
        {
            // original === channel, so it should not matter which
            // gets assigned here
            self = .connected(connection)
        }
        else
        {
            fatalError("unreachable: connection.channel !== original")
        }
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
        case (nil, .connected):
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
    /// afterwards, preventing further use of the connection state descriptor.
    /// The optional will always be [`nil`]() after calling this method.
    @inlinable public mutating
    func remove<Member>() where Wrapped == MongoConnection<Member>.State
    {
        self?.connection?.channel.heart.stop()
        self = nil
    }
}
