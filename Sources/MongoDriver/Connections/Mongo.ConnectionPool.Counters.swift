// extension Mongo.ConnectionPool
// {
//     struct Counters
//     {
//         private
//         var current:
//         (
//             connection:UInt,
//             request:UInt
//         )

//         init()
//         {
//             self.current = (0, 0)
//         }
//     }
// }
// extension Mongo.ConnectionPool.Counters
// {
//     
//     mutating
//     func connection() -> UInt
//     {
//         self.current.connection += 1
//         return self.current.connection
//     }
//     
//     mutating
//     func request() -> UInt
//     {
//         self.current.request += 1
//         return self.current.request
//     }
// }
