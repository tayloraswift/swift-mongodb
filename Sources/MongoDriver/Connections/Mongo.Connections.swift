import MongoChannel

extension Mongo
{
    /// Categorizes and tracks channels by their observed health and
    /// allocation status.
    struct Connections
    {
        /// Connections that are currently free to be allocated,
        /// and are believed to be healthy.
        private
        var released:Set<MongoChannel>
        /// Connections that are currently allocated and are 
        /// believed to be healthy.
        private
        var retained:Set<MongoChannel>
        /// Connections that are currently allocated but are *not*
        /// believed to be healthy.
        /// Does not contribute to pool ``width``, but does affect
        /// ``isEmpty``.
        private
        var perished:Set<MongoChannel>

        /// Additional channels that have no other way of being
        /// represented in this structure. Contributes to both
        /// ``width`` and ``isEmpty``.
        var pending:Int

        init()
        {
            self.released = []
            self.retained = []
            self.perished = []
            self.pending = 0
        }
    }
}
extension Mongo.Connections
{
    /// Indicates if the structure is completely devoid of channels,
    /// including pending and perished channels. It is possible for
    /// this to be [`false`]() while ``width`` is zero.
    var isEmpty:Bool
    {
        self.released.isEmpty &&
        self.retained.isEmpty &&
        self.perished.isEmpty &&
        self.pending == 0
    }
    /// The number of non-perished channels, including pending channels
    /// currently known to this structure. It is possible for this to be
    /// zero while ``isEmpty`` is [`false`](), if this structure contains
    /// at least one perished channel.
    var width:Int
    {
        self.pending + self.released.count + self.retained.count
    }
}
extension Mongo.Connections
{
    /// Unconditionally inserts the given channel into the set of released
    /// channels. Increments the connection count.
    ///
    /// Traps if the channel is already in the set of released channels.
    mutating
    func insert(_ channel:MongoChannel)
    {
        guard case nil = self.released.update(with: channel)
        else
        {
            fatalError("unreachable (inserted a channel more than once!)")
        }
    }
    /// Unconditionally removes the given channel from either the set of
    /// retained channels, or the set of perished channels. Decrements
    /// the connection count, and may decrement the pool width.
    ///
    /// Traps if the channel is not in either set, even if the channel
    /// exists in the set of released channels.
    mutating
    func remove(_ channel:MongoChannel)
    {
        if      case _? = self.retained.remove(channel)
        {
            return
        }
        else if case _? = self.perished.remove(channel)
        {
            return
        }
        fatalError("unreachable (removed a channel more than once!)")
    }
    /// Removes the channel from the set of released channels if it
    /// is present there, otherwise moves the channel from the set of
    /// retained channels to the set of perished channels, if it is
    /// present in the set of retained channels. Does nothing if it
    /// in not present in either set, which is expected if a call to
    /// this method loses a race with ``remove(_:)``.
    ///
    /// May decrement the the connection count and/or the pool width.
    ///
    /// Traps if the channel already exists in the set of perished
    /// channels.
    mutating
    func perish(_ channel:MongoChannel)
    {
        guard case nil = self.released.remove(channel)
        else
        {
            return
        }
        guard case  _? = self.retained.remove(channel)
        else
        {
            //  lost the race with ``remove(_:)``
            return
        }
        guard case nil = self.perished.update(with: channel)
        else
        {
            fatalError("unreachable (perished a channel more than once!)")
        }
    }
    /// Removes the given channel from the set of perished channels if it
    /// is present there, otherwise transfers the channel from the set of
    /// retained channels to the set of released channels. Decrements
    /// connection count, but does not affect pool width. (Because the
    /// channel will only be removed if it is already perished.)
    ///
    /// Traps if neither operation could be performed.
    mutating
    func checkin(_ channel:MongoChannel)
    {
        if      case  _? = self.perished.remove(channel)
        {
            return
        }
        else if case  _? = self.retained.remove(channel),
                case nil = self.released.update(with: channel)
        {
            return
        }
        else 
        {
            fatalError("unreachable (checked in a channel more than once!)")
        }
    }
    /// Pops a channel from the set of released channels, if one is
    /// available, and transfers it to the set of retained channels.
    /// Returns a reference to the channel, if it exists.
    ///
    /// Traps if the transfer could not be performed.
    mutating
    func checkout() -> MongoChannel?
    {
        guard let channel:MongoChannel = self.released.popFirst()
        else
        {
            return nil
        }
        if case nil = self.retained.update(with: channel)
        {
            return channel
        }
        else
        {
            fatalError("unreachable (checked out a channel more than once!)")
        }
    }

    /// Clears and returns the set of released channels. Currently-retained
    /// channels, including perished channels, are unaffected.
    mutating
    func shrink() -> Set<MongoChannel>
    {
        defer { self.released = [] }
        return  self.released
    }
    /// Interrupts all currently-retained channels. Currently-released
    /// channels, and perished channels, are unaffected.
    func interrupt()
    {
        self.retained.interrupt()
    }
}
