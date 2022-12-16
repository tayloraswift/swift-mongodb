import TraceableErrors

extension Mongo
{
    public
    struct SessionMediumError:Error
    {
        public
        let selector:SessionMediumSelector
        public
        let hosts:[Mongo.Host: any Error]

        public
        init(selector:SessionMediumSelector, errored hosts:[Mongo.Host: any Error])
        {
            self.selector = selector
            self.hosts = hosts
        }
    }
}
extension Mongo.SessionMediumError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        guard lhs.selector == rhs.selector
        else
        {
            return false
        }
        var lhs:[Mongo.Host: any Error] = lhs.hosts
        for (key, rhs):(Mongo.Host, any Error) in rhs.hosts
        {
            guard   let lhs:any Error = lhs.removeValue(forKey: key),
                        lhs == rhs
            else
            {
                return false
            }
        }
        return lhs.isEmpty
    }
}
extension Mongo.SessionMediumError:TraceableError
{
    public
    var underlying:any Error
    {
        Mongo.SessionMediumTimeoutError.init(selector: self.selector) as any Error
    }
    public
    var notes:[String]
    {
        self.hosts.sorted
        {
            $0.key < $1.key
        }
            .map
        {
            """
            host '\($0.key)' could not reached because:
            \(String.init(describing: $0.value).split(separator: "\n",
                omittingEmptySubsequences: false).lazy.map
            {
                "    " + $0
            }
            .joined(separator: "\n"))
            """
        }
    }
}
