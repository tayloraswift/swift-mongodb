extension MongoTopology
{
    @frozen public
    struct TagSet
    {
        public
        let filter:[(key:String, value:String)]
    }
}
extension MongoTopology.TagSet
{
    @inlinable public static
    func ~= (lhs:Self, rhs:[String: String]) -> Bool
    {
        for (key, value):(String, String) in lhs.filter
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
