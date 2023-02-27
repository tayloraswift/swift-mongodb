import TraceableErrors

extension Mongo
{
    public
    struct ConnectionPoolStateError:Error
    {
        let reason:any Error

        init(because reason:any Error)
        {
            self.reason = reason
        }
    }
}
extension Mongo.ConnectionPoolStateError:TraceableError
{
    public
    var underlying:any Error
    {
        Mongo.ConnectionPoolDrainedError.init() as any Error
    }
    public
    var notes:[String]
    {
        ["Pool was originally drained because of '\(self.reason)'"]
    }
}
