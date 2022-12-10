import TraceableErrors

extension Mongo
{
    public
    struct ConnectionErrors:Error, Sendable
    {
        public
        let selector:ServerSelector
        public
        let errors:[(host:Host, error:any Error)]
        
        public 
        init(selector:ServerSelector, errors:[(host:Host, error:any Error)])
        {
            self.selector = selector
            self.errors = errors
        }
    }
}
extension Mongo.ConnectionErrors:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.selector == rhs.selector &&
        lhs.errors.elementsEqual(rhs.errors)
        {
            $0.host == $1.host &&
            $0.error == $1.error
        }
    }
}
extension Mongo.ConnectionErrors:TraceableError
{
    public
    var underlying:any Error
    {
        Mongo.ServerSelectionError.init(self.selector) as any Error
    }
    public
    var notes:[String]
    {
        self.errors.map
        {
            """
            host '\($0.host)' could not reached because:
            \(String.init(describing: $0.error).split(separator: "\n",
                omittingEmptySubsequences: false).lazy.map
            {
                "    " + $0
            }
            .joined(separator: "\n"))
            """
        }
    }
}
