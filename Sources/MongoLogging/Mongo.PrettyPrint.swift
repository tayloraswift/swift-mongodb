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
extension Mongo.PrettyPrint:Mongo.LogTarget
{
    public
    func log<Event>(event:Event) where Event:Mongo.LogEvent
    {
        print("MongoDB \(event.severity): \(event)")
    }
}
