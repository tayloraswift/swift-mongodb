import MongoDB

extension CausalConsistency
{
    struct AnyTimeoutError:Error
    {
        private
        init()
        {
        }
    }
}
extension CausalConsistency.AnyTimeoutError
{
    init?(_ error:any Error)
    {
        switch error
        {
        case    is Mongo.DriverTimeoutError,
                is Mongo.WireTimeoutError:
            self.init()

        case let error as Mongo.ServerError:
            guard error.code.indicatesTimeLimitExceeded
            else
            {
                return nil
            }

            self.init()

        case _:
            return nil
        }
    }
}
