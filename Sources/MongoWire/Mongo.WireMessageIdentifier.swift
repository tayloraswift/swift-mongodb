extension Mongo
{
    @frozen public
    struct WireMessageIdentifier:Hashable, Sendable
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
extension Mongo.WireMessageIdentifier
{
    @inlinable public mutating
    func next() -> Self
    {
        self.value += 1
        return self
    }
}
extension Mongo.WireMessageIdentifier
{
    public static
    let none:Self = .init(0)
}
extension Mongo.WireMessageIdentifier:CustomStringConvertible
{
    public
    var description:String
    {
        self.value.description
    }
}
