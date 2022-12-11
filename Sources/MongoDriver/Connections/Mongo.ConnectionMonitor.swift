// import Heartbeats

// extension Mongo
// {
//     enum ConnectionMonitor
//     {
//         case connected(Heart)
//         case disconnected
//     }
// }
// extension Mongo.ConnectionMonitor
// {
//     mutating
//     func restart() -> Heartbeat?
//     {
//         switch self
//         {
//         case .connected(let heart):
//             //  hangover from a previous cycle. heart is most likely
//             //  stopped already, but stop it again just in case
//             heart.stop()
//             fallthrough
        
//         case .disconnected:
//             let heartbeat:Heartbeat = .init(interval: .milliseconds(1000))
//             self = .connected(heartbeat.heart)
//             return heartbeat
//         }
//     }
// }
// extension Mongo.ConnectionMonitor?
// {
//     mutating
//     func remove()
//     {
//         if case .connected(let heart)? = self
//         {
//             heart.stop()
//         }
//         self = nil
//     }
// }
// extension Mongo
// {
//     struct DeploymentMonitor
//     {
//         private
//         var counter:UInt
//         private
//         var monitors:[UInt: ConnectionMonitor]

//         init()
//         {
//             self.counter = 0
//             self.monitors = [:]
//         }
//     }
// }
// extension Mongo.DeploymentMonitor
// {
//     mutating
//     func create() -> UInt
//     {
//         let id:UInt = self.counter
//         self.counter += 1
//         self.monitors[id] = .disconnected
//         return id
//     }

//     subscript(id:UInt) -> Mongo.ConnectionMonitor?
//     {
//         _read
//         {
//             yield  self.monitors[id]
//         }
//         _modify
//         {
//             yield &self.monitors[id]
//         }
//     }

//     mutating
//     func removeAll()
//     {
//         while let key:UInt = self.monitors.keys.first
//         {
//             self.monitors[key].remove()
//         }
//     }
// }
// extension Mongo.DeploymentMonitor?
// {
//     mutating
//     func remove()
//     {
//         self?.removeAll()
//         self = nil
//     }
// }
