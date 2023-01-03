import BSONEncoding

extension MongoTopology
{
    /// A MongoDB tag set.
    @frozen public
    struct TagSet
    {
        /// The list of patterns that make up this tag set. Tag sets
        /// are like ordered dictionaries, but they never perform key
        /// lookups, so this is modeled as a plain array.
        public
        let patterns:[(key:String, value:String)]

        @inlinable public
        init(patterns:[(key:String, value:String)])
        {
            self.patterns = patterns
        }
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
extension MongoTopology.TagSet:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(String, String)...)
    {
        self.init(patterns: dictionaryLiteral)
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
