extension MongoWire
{
    @frozen public
    struct MessageIdentifier:Hashable, Sendable
    {
        public
        var value:Int32

        @inlinable public
        init(_ value:Int32)
        {
            self.value = value
        }
    }
}
extension MongoWire.MessageIdentifier
{
    @inlinable public mutating
    func next() -> Self
    {
        self.value += 1
        return self
    }
}
extension MongoWire.MessageIdentifier
{
    public static
    let none:Self = .init(0)
}
extension MongoWire.MessageIdentifier:CustomStringConvertible
{
    public
    var description:String
    {
        self.value.description
    }
}
