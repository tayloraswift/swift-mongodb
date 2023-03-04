extension Mongo
{
    /// A command timed out during execution.
    public
    enum TimeoutError:Error, Equatable, Sendable
    {
        /// A command was timed-out by the driver. If `written` is false,
        /// then the command was never written to a channel in the first
        /// place, because the deadline for the command had already passed.
        ///
        /// Driver-side timeouts are expensive, because the driver needs to
        /// tear down and re-establish connections after enforcing them.
        case driver(written:Bool)
        /// A command was timed-out by the server, most likely according to
        /// `maxTimeMS` (``MaxTime``). The payload indicates the exact type
        /// of timeout reported by the server.
        ///
        /// Server-side timeouts are efficient, because the driver can reuse
        /// the connection used to run the original command to run another
        /// command.
        case server(code:ServerError.Code)
    }
}
