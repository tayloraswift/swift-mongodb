extension Mongo.Create<Mongo.Collection>
{
    @frozen public
    enum Cap:String, Hashable, Sendable
    {
        case cap
    }
}
extension Mongo.Create.Cap
{
    @available(*, unavailable,
        message: "Specify capped collection options together with 'cap'.")
    public static
    var capped:Self
    {
        fatalError()
    }
    @available(*, unavailable,
        message: "Specify capped collection options together with 'cap'.")
    public static
    var size:Self
    {
        fatalError()
    }
    @available(*, unavailable,
        message: "Specify capped collection options together with 'cap'.")
    public static
    var max:Self
    {
        fatalError()
    }
}
