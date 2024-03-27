import Durations
import MongoCommands

extension Mongo
{
    public
    enum CursorLifecycle
    {
        /// The timeout used for ``GetMore`` operations on the relevant cursor.
        case iterable(Milliseconds?)
        case expires(ContinuousClock.Instant)
    }
}
extension Mongo.CursorLifecycle
{
    @inlinable
    var timeout:Mongo.MaxTime
    {
        switch self
        {
        //  maxTimeMS can only be sent for tailable
        //  (iteration-based lifecycle) cursors.
        case .iterable: .computed
        case .expires:  .omitted
        }
    }
}
