extension Mongo
{
    public
    protocol LogTarget:Sendable
    {
        func log(event:some LogEvent)
    }
}
