extension Mongo.Cursor
{
    @frozen public
    struct State:Sendable
    {
        public
        var elements:[Element]
        public
        var next:Mongo.CursorHandle

        @inlinable public
        init(elements:[Element], next:Mongo.CursorHandle)
        {
            self.elements = elements
            self.next = next
        }
    }
}
extension Mongo.Cursor.State:Equatable where Element:Equatable
{
}
extension Mongo.Cursor.State
{
    // @inlinable public
    // var next:Mongo.CursorIdentifier?
    // {
    //     .init(self.handle)
    // }
    @inlinable public
    var batch:[Element]?
    {
        self.elements.isEmpty ? nil : self.elements
    }
    @inlinable public mutating
    func pop() -> [Element]?
    {
        if let batch:[Element] = self.batch
        {
            self.elements = []
            return batch
        }
        else
        {
            return nil
        }
    }
}
