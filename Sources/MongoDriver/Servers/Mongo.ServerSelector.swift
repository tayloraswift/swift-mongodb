extension Mongo
{
    @frozen public
    enum ServerSelector:Sendable
    {
        case master
        case any
    }
}
extension Mongo.ServerSelector
{
    static
    func ~= (self:Self, server:Mongo.Server) -> Bool
    {
        if case .master = self
        {
            if  server.isReadOnly
            {
                return false
            }
            if !server.isWritablePrimary
            {
                return false
            }
        }
        return true
    }
}
