extension Mongo
{
    @frozen public
    enum ConnectionPoolEvent:Sendable
    {
        case creating(ConnectionPoolSettings)
        case draining(because:any Error)
        case drained

        case expanding(id:UInt)
        case expanded(id:UInt)
        case perished(id:UInt, because:Result<Void, any Error>)
        case removed(id:UInt)

        case creatingConnection
        case createdConnection
        case destroyedConnection
    }
}
