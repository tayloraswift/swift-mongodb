extension Mongo
{
    public
    enum LoggingLevel:UInt8
    {
        case full = 1
    }
}
extension Mongo.LoggingLevel:Comparable
{
    public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
