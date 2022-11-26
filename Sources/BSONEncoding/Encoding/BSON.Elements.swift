extension BSON.Elements
{
    @inlinable public
    init<Encodable>(_ elements:some Sequence<Encodable>) where Encodable:BSONEncodable
    {
        self.init
        {
            for element:Encodable in elements
            {
                $0.append(element)
            }
        }
    }
    @inlinable public mutating
    func append(_ element:some BSONEncodable)
    {
        self.append(with: element.encode(to:))
    }
}
