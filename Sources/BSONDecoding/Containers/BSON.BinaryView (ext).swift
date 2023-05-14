extension BSON.BinaryView
{
    @inlinable public
    var shape:BSON.Shape
    {
        .init(length: self.slice.count)
    }
}
