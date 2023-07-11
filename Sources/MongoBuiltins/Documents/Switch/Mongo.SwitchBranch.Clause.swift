extension Mongo.SwitchBranch
{
    @frozen public
    enum Clause:String, Hashable, Sendable
    {
        case `case`
        case  then
    }
}
