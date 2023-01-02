import MongoTopology
import TraceableErrors

extension Mongo
{
    public
    struct ClusterError<Underlying>:Error where Underlying:Error
    {
        public
        let diagnostics:MongoTopology.Diagnostics
        public
        let failure:Underlying

        public
        init(diagnostics:MongoTopology.Diagnostics, failure:Underlying)
        {
            self.diagnostics = diagnostics
            self.failure = failure
        }
    }
}
extension Mongo.ClusterError:Equatable where Underlying:Equatable
{
}
extension Mongo.ClusterError:TraceableError
{
    public
    var underlying:any Error
    {
        self.failure as any Error
    }
    public
    var notes:[String]
    {
        self.diagnostics.notes
    }
}
