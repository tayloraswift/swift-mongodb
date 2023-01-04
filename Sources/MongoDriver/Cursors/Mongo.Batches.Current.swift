extension Mongo.Batches
{
    public final
    class Current
    {
        public
        var elements:[BatchElement]
        public
        var handle:Int64

        @inlinable public
        init(elements:[BatchElement], handle:Int64)
        {
            self.elements = elements
            self.handle = handle
        }
    }
}
extension Mongo.Batches.Current
{
    @inlinable public
    var next:Mongo.CursorIdentifier?
    {
        .init(rawValue: self.handle)
    }

    @inlinable public
    func move() -> [BatchElement]
    {
        defer
        {
            self.elements = []
        }
        return self.elements
    }
}
