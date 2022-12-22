import Heartbeats

extension MongoChannel
{
    @frozen public
    enum State<Metadata>
    {
        case connected(MongoChannel, metadata:Metadata)
        case errored(any Error)
        case queued
    }
}
extension MongoChannel.State
{
    /// Returns the stored metadata, if this descriptor currently has any.
    @inlinable public
    var metadata:Metadata?
    {
        if case .connected(_, metadata: let metadata) = self
        {
            return metadata
        }
        else
        {
            return nil
        }
    }
    /// Returns the stored channel, if this descriptor currently has one.
    @inlinable public
    var channel:MongoChannel?
    {
        if case .connected(let channel, metadata: _) = self
        {
            return channel
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
extension MongoChannel.State
{
    /// Updates the metadata for the stored channel.
    /// If this descriptor does not already have a channel, the
    /// `channel` argument will be stored in it.
    ///
    /// -   Parameters:
    ///     -   channel: A wrapped NIO channel. If this descriptor already has one,
    ///         the parameter must be identical to it.
    ///     -   metadata: The metadata to update.
    ///
    /// -   Returns: [`true`](), always.
    @inlinable public mutating
    func update(channel:MongoChannel, metadata:Metadata) -> Bool
    {
        guard let original:MongoChannel = self.channel
        else
        {
            self = .connected(channel, metadata: metadata)
            return true
        }
        if channel === original
        {
            // original === channel, so it should not matter which
            // gets assigned here
            self = .connected(original, metadata: metadata)
            return true
        }
        else
        {
            fatalError("unreachable: channel !== original")
        }
    }
    /// Places this descriptor in an ``case errored(_:)`` or ``case queued``
    /// state. If `status` is [`nil`]() and the descriptor is already in
    /// an errored state, the descriptor will remain in that state, and the
    /// stored error will not be overwritten.
    ///
    /// -   Returns: [`true`](), always.
    @discardableResult
    @inlinable public mutating
    func clear(status:(any Error)?) -> Bool
    {
        // only overwrite an existing error if we have a new one
        switch (self, status)
        {
        case (.errored(_), nil):
            break
        case (_, nil):
            self = .queued
        case (_, let error?):
            self = .errored(error)
        }
        return true
    }
}

extension Optional
{
    /// Sends a termination signal to the monitoring thread for this
    /// channel if non-[`nil`](), and sets this optional to [`nil`]()
    /// afterwards, preventing further use of the channel state descriptor.
    /// The optional will always be [`nil`]() after calling this method.
    ///
    /// -   Returns: [`false`](), always.
    @discardableResult
    @inlinable public mutating
    func remove<Member>() -> Bool where Wrapped == MongoChannel.State<Member>
    {
        self?.channel?.heart.stop()
        self = nil
        return false
    }
}
