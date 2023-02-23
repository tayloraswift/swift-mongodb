import NIOCore

extension Sequence where Element:MongoExecutor
{
    /// Closes all channels in this sequence (concurrently), returning when
    /// every channel has been closed.
    @inlinable public
    func close() async
    {
        await withTaskGroup(of: Void.self)
        {
            (tasks:inout TaskGroup<Void>) in

            for executor:Element in self
            {
                let channel:any Channel = executor.channel

                tasks.addTask
                {
                    Element.interrupt(channel)
                }
            }
        }
    }
}
