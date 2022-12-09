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
        guard case .connected(let original, metadata: _) = self
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
}
extension Mongo.ConnectionState<Mongo.Replica?>
{
    mutating
    func clearPrimaryAndQueueRecheck()
    {
        if case .connected(let connection, metadata: .primary(_)?) = self
        {
            connection.heart.beat()
            self.clear(status: nil)
        }
        else
        {
            fatalError("unreachable: cannot call \(#function) on a replica that is not the primary")
        }
    }
}

extension Optional
{
    mutating
    func remove<Member>()
        where Wrapped == Mongo.ConnectionState<Member>
    {
        if case .connected(let connection, metadata: _)? = self
        {
            connection.heart.stop()
        }
        self = nil
    }
}
