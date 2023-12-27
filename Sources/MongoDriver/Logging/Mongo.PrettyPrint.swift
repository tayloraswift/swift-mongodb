extension Mongo
{
    public
    struct PrettyPrint
    {
        public
        init()
        {
        }
    }
}
extension Mongo.PrettyPrint:Mongo.LoggingTarget
{
    public
    func log(level:Mongo.LoggingLevel, event:Mongo.LoggingEvent)
    {
        print(event.description)
    }
}
