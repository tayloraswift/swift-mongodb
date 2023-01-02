import BSONEncoding

extension MongoTopology
{
    @frozen public
    struct TagSet
    {
        public
        let patterns:[(key:String, value:String)]
    }
}
extension MongoTopology.TagSet:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.patterns.elementsEqual(rhs.patterns, by: == )
    }
}
extension MongoTopology.TagSet
{
    @inlinable public static
    func ~= (lhs:Self, rhs:[String: String]) -> Bool
    {
        for (key, value):(String, String) in lhs.patterns
        {
            guard case value? = rhs[key]
            else
            {
                return false
            }
        }
        return true
    }
}
extension MongoTopology.TagSet:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        for (key, value):(String, String) in self.patterns
        {
            bson[key] = value
        }
    }
}
