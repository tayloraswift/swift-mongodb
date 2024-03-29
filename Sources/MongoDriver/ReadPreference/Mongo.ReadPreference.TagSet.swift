import BSON

extension Mongo.ReadPreference
{
    /// A MongoDB tag set.
    @frozen public
    struct TagSet
    {
        /// The list of patterns that make up this tag set. Tag sets
        /// are like ordered dictionaries, but they never perform key
        /// lookups, so this is modeled as a plain array.
        public
        let patterns:[(key:BSON.Key, value:String)]

        @inlinable public
        init(patterns:[(key:BSON.Key, value:String)])
        {
            self.patterns = patterns
        }
    }
}
extension Mongo.ReadPreference.TagSet:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.patterns.elementsEqual(rhs.patterns, by: == )
    }
}
extension Mongo.ReadPreference.TagSet:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(BSON.Key, String)...)
    {
        self.init(patterns: dictionaryLiteral)
    }
}
extension Mongo.ReadPreference.TagSet
{
    @inlinable public static
    func ~= (lhs:Self, rhs:[BSON.Key: String]) -> Bool
    {
        for (key, value):(BSON.Key, String) in lhs.patterns
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
extension Mongo.ReadPreference.TagSet:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        for (key, value):(BSON.Key, String) in self.patterns
        {
            bson[key] = value
        }
    }
}
