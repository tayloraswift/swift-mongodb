// extension Mongo
// {
//     struct ConnectionMetadata<Server>
//     {
//         let server:Server
//         let token:Mongo.ConnectionToken

//         init(_ server:Server, token:Mongo.ConnectionToken)
//         {
//             self.server = server
//             self.token = token
//         }
//     }
// }
// extension Mongo.ConnectionMetadata
// {
//     func map<T>(_ transform:(Server) throws -> T) rethrows -> Mongo.ConnectionMetadata<T>
//     {
//         .init(try transform(self.server), token: self.token)
//     }
// }
