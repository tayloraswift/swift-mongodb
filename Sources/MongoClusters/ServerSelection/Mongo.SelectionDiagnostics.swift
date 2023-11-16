extension Mongo
{
    public
    struct SelectionDiagnostics:Equatable, Sendable
    {
        public
        var unreachable:[Host: Unreachable]
        public
        var undesirable:[Host: Undesirable]
        public
        var unsuitable:[Host: Unsuitable]

        public
        init(unreachable:[Host: Unreachable] = [:],
            undesirable:[Host: Undesirable] = [:],
            unsuitable:[Host: Unsuitable] = [:])
        {
            self.unreachable = unreachable
            self.undesirable = undesirable
            self.unsuitable = unsuitable
        }
    }
}
extension Mongo.SelectionDiagnostics
{
    public
    var notes:[String]
    {
        self.unsuitable.sorted
        {
            $0.key < $1.key
        }
            .map
        {
            let reason:String
            switch $0.value
            {
            case .stale(let milliseconds):
                reason = "it is too stale (\(milliseconds) ms)."

            case .tags(let tags):
                reason = "its tags don’t match any tag sets (\(tags))."
            }
            return "host '\($0.key)' was not chosen because \(reason)"
        }
        +
        self.undesirable.sorted
        {
            $0.key < $1.key
        }
            .map
        {
            """
            host '\($0.key)' was not chosen because it is a(n) '\($0.value)'.
            """
        }
        +
        self.unreachable.sorted
        {
            $0.key < $1.key
        }
            .map
        {
            let reason:String
            switch $0.value
            {
            case .queued:
                reason = " it has not completed its handshake."

            case .errored(let error):
                reason = ":\n" + String.init(describing: error).split(separator: "\n",
                    omittingEmptySubsequences: false).lazy.map
                {
                    "    " + $0
                }
                .joined(separator: "\n")
            }

            return "host '\($0.key)' could not reached because\(reason)"
        }
    }
}
