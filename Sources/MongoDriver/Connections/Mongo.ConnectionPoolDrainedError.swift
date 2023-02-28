import TraceableErrors

extension Mongo
{
    public
    struct ConnectionPoolDrainedError:Error
    {
        public
        let underlying:any Error

        init(because error:any Error)
        {
            self.underlying = error
        }
    }
}
extension Mongo.ConnectionPoolDrainedError:TraceableError
{
    public
    var notes:[String]
    {
        [
            """
            """
        ]
    }
}
