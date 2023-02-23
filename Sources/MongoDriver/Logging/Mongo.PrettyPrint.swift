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
extension Mongo.PrettyPrint:MongoLoggingTarget
{
    public
    func log(level:Mongo.LoggingLevel, event:Mongo.LoggingEvent)
    {
        print(event.description)
    }
}
