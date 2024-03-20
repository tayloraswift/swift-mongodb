extension Mongo
{
    public
    protocol LogEvent:Sendable
    {
        var severity:LogSeverity { get }
    }
}
