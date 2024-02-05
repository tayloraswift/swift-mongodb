extension Array:BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        let list:BSON.List = try .init(bson: consume bson)

        self.init()
        try list.parse
        {
            self.append(try $0.decode(to: Element.self))
        }
    }
}
