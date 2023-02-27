extension Mongo.ConnectionPool
{
    /// The current stage of a connection pool’s lifecycle.
    enum Phase
    {
        // var connector:Mongo.Connector<Mongo.Authenticator>?
        // let caller:CheckedContinuation<Void, Never>
        /// The connection pool is active and can create new connections.
        case filling(CheckedContinuation<Void, Never>, Mongo.Connector<Mongo.Authenticator>)
        /// The connection pool is inactive and cannot create new connections.
        case draining(CheckedContinuation<Void, Never>, Mongo.ConnectionPoolStateError)
        case drained(Mongo.ConnectionPoolStateError)
    }
}


// extension Mongo.ConnectionPool
// {
//     enum CheckoutResult
//     {
//         case available(Mongo.ConnectionAllocation)
//         case pending(UInt, Mongo.Connector<Mongo.Authenticator>)
//         case blocked(UInt)
//     }
// }

// extension Mongo.ConnectionPool
// {
//     struct FillingState
//     {
//         let connector:Mongo.Connector<Mongo.Authenticator>

//         var connections:Mongo.Connections
//         var counters:Counters
//     }
// }
// extension Mongo.ConnectionPool.FillingState
// {
//     mutating
//     func checkout(releasing:UnsafeAtomic<Int>,) -> Mongo.ConnectionPool.CheckoutResult
//     {
//         if  let allocation:Mongo.ConnectionAllocation = self.connections.checkout()
//         {
//             return .available(allocation)
//         }
//         if  self.connections.pending < self.settings.rate,
//             self.connections.count < self.settings.size.upperBound,
//             self.releasing.load(ordering: .relaxed) <= self.requests.count
//         {
//             // note: this checks for awaiting requests, and may use the
//             // newly-established connection to succeed a different request.
//             // so it is not guaranteed that the next iteration of the loop
//             // will yield a channel.
//             await self.expand(using: connector)
//         }
//         else
//         {
//             let request:UInt = self.next.request()
//     }
// }
