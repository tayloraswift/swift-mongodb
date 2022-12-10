extension Mongo
{
    enum ConnectionState<Metadata>
    {
        case connected(Connection, metadata:Metadata)
        case errored(any Error)
        case queued
    }
}
extension Mongo.ConnectionState
{
    /// Returns the stored metadata, if this descriptor currently has any.
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
    /// Returns the stored connection, if this descriptor currently has one.
    var connection:Mongo.Connection?
    {
        if case .connected(let connection, metadata: _) = self
        {
            return connection
        }
        else
        {
            return nil
        }
    }
}
extension Mongo.ConnectionState<Mongo.Replica?>
{
    /// Returns the stored connection, if this descriptor currently has one,
    /// and its metadata indicates it is a primary replica.
    var primary:Mongo.Connection?
    {
        if case .connected(let connection, metadata: .primary(_)?) = self
        {
            return connection
        }
        else
        {
            return nil
        }
    }
}
extension Mongo.ConnectionState
{
    /// Updates the metadata for the stored connection.
    /// If this descriptor does not already have a connection, the
    /// `connection` argument will be stored in it.
    ///
    /// -   Parameters:
    ///     -   connection: A wrapped NIO channel. If this descriptor already has one,
    ///         the parameter must be identical to it.
    ///     -   metadata: The metadata to update.
    mutating
    func update(connection:Mongo.Connection, metadata:Metadata)
    {
        guard let original:Mongo.Connection = self.connection
        else
        {
            self = .connected(connection, metadata: metadata)
            return
        }
        if connection === original
        {
            // original === connection, so it should not matter which
            // gets assigned here
            self = .connected(original, metadata: metadata)
        }
        else
        {
            fatalError("unreachable: connection !== original")
        }
    }
    /// Places this descriptor in an ``case errored(_:)`` or ``case queued``
    /// state. If `status` is [`nil`]() and the descriptor is already in
    /// an errored state, the descriptor will remain in that state, and the
    /// stored error will not be overwritten.
    mutating
    func clear(status:(any Error)?)
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
    }
    /// Sends a termination signal to the monitoring thread for this
    /// connection. After calling this method, the connection descriptor
    /// is no longer in a valid state, and you must not call any other
    /// methods on it. Prefer calling the mutating ``Optional.remove()``
    /// method where type context permits.
    func end()
    {
        self.connection?.heart.stop()
    }
    /// Sends a termination signal to the monitoring thread for this
    /// connection, along with the ``EndSessions`` command if available.
    /// If the ``EndSessions`` command is thrown to the monitoring thread,
    /// the `command` binding will be set to [`nil`](). After calling this
    /// method, the connection descriptor is no longer in a valid state,
    /// and you must not call any other methods on it.
    ///
    /// Note that throwing the ``EndSessions`` command does not guarantee
    /// that the monitoring thread will see it. For example, it may have
    /// already received a termination signal for a different reason.
    func end(sessions command:inout Mongo.EndSessions?)
    {
        if case ()? = self.connection?.heart.stop(throwing: command)
        {
            command = nil
        }
    }
}

extension Optional
{
    /// Calls the ``Mongo/ConnectionState.end()`` method if non-[`nil`](),
    /// and sets this optional to [`nil`]() afterwards, preventing
    /// further use of the connection state descriptor.
    /// The optional will always be [`nil`]() after calling this method.
    mutating
    func remove<Member>() where Wrapped == Mongo.ConnectionState<Member>
    {
        self?.end()
        self = nil
    }
}
