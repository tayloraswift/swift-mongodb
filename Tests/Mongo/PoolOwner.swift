final
class PoolOwner
{
    let pool:Pool

    init(_ pool:Pool)
    {
        self.pool = pool
    }

    deinit
    {
        self.pool.drained = true
    }
}
