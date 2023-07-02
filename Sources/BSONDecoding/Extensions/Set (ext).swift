extension Set:BSONListViewDecodable, BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>) throws
    {
        self.init()
        try bson.parse
        {
            self.update(with: try $0.decode(to: Element.self))
        }
    }
}
