import TraceableErrors
import MongoClusters

extension Mongo
{
    public
    struct DeploymentStateError<Underlying>:Error where Underlying:Error
    {
        public
        let diagnostics:Mongo.SelectionDiagnostics
        public
        let failure:Underlying

        public
        init(diagnostics:Mongo.SelectionDiagnostics, failure:Underlying)
        {
            self.diagnostics = diagnostics
            self.failure = failure
        }
    }
}
extension Mongo.DeploymentStateError:Equatable where Underlying:Equatable
{
}
extension Mongo.DeploymentStateError:TraceableError
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
