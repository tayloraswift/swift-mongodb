// import BSON
// import BSONBuilder
// import MongoWire
// import NIOCore

// /// @import(NIOCore)
// /// A channel to a `mongod`/`mongos` host. This type is a thin wrapper around an
// /// NIO ``Channel`` and provides no lifecycle management.
// public
// struct MongoChannel:Sendable
// {
//     @usableFromInline
//     let channel:any Channel

//     /// Wraps the provided NIO ``Channel`` without attaching any heartbeat
//     /// controller.
//     public
//     init(_ channel:any Channel)
//     {
//         self.channel = channel
//     }
// }

// extension MongoChannel:Equatable
// {
//     @inlinable public static
//     func == (lhs:Self, rhs:Self) -> Bool
//     {
//         lhs.channel === rhs.channel
//     }
// }
// extension MongoChannel:Hashable
// {
//     @inlinable public
//     func hash(into hasher:inout Hasher)
//     {
//         hasher.combine(ObjectIdentifier.init(self.channel))
//     }
// }

