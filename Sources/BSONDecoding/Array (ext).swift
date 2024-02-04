extension Array:BSONListViewDecodable, BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.ListView) throws
    {
        self.init()
        try bson.parse
        {
            self.append(try $0.decode(to: Element.self))
        }
    }
}
