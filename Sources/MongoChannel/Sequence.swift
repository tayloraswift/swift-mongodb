extension Sequence<MongoChannel>
{
    /// Closes all channels in this sequence (concurrently), returning when
    /// every channel has been closed.
    @inlinable public
    func close() async
    {
        await withTaskGroup(of: Void.self)
        {
            (tasks:inout TaskGroup<Void>) in

            for channel:MongoChannel in self
            {
                tasks.addTask
                {
                    await channel.close()
                }
            }
        }
    }
    /// Interrupts all channels in this sequence.
    @inlinable public
    func interrupt()
    {
        for channel:MongoChannel in self
        {
            channel.interrupt()
        }
    }
}
