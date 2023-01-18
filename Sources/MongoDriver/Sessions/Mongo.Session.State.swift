extension Mongo.Session
{
    @usableFromInline final
    class State
    {
        @usableFromInline
        var operationTime:Mongo.Instant?
        @usableFromInline
        var metadata:Mongo.SessionMetadata

        init(_ metadata:Mongo.SessionMetadata)
        {
            self.operationTime = nil
            self.metadata = metadata
        }
    }
}
extension Mongo.Session.State
{
    @usableFromInline
    func update(touched:ContinuousClock.Instant,
        operationTime:Mongo.Instant?)
    {
        self.metadata.touched = touched
        //  observed operation times will not necessarily be monotonic, if
        //  commands are being sent to different servers across the same
        //  session. to enforce causal consistency, we must only update the
        //  operation time if it is greater than the stored operation time.
        guard let operationTime:Mongo.Instant
        else
        {
            return
        }
        guard let recordedTime:Mongo.Instant = self.operationTime
        else
        {
            self.operationTime = operationTime
            return
        }
        if  recordedTime < operationTime
        {
            self.operationTime = operationTime
        }
    }
}
