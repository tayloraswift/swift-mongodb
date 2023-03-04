extension Mongo
{
    public
    enum CommandType:String, Hashable, Sendable
    {
        case abortTransaction
        case commitTransaction
        case configureFailpoint = "configureFailPoint"
    }
}
