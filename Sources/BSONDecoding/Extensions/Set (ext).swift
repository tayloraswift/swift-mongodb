extension Set:BSONListViewDecodable, BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.ListView) throws
    {
        self.init()
        try bson.parse
        {
            self.update(with: try $0.decode(to: Element.self))
        }
    }
}
