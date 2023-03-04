extension Mongo.ConnectionPool
{
    enum AllocationResult
    {
        case available(Allocation)
        case reserved(Reservation)
        case blocked(UInt)
        case failure(Mongo.ConnectionPoolDrainedError)
    }
}
