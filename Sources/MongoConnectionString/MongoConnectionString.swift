import Durations
import MongoDriver
import MongoTopology

@frozen public
struct MongoConnectionString:Sendable
{
    public
    var user:(name:String, password:String)?
    public 
    var discovery:MongoTopology.Discovery
    public
    var defaultauthdb:Mongo.Database?

    public
    var tls:Bool
    public
    var tlsCAFile:String?
    public
    var connectTimeout:Milliseconds?
    public
    var socketTimeout:Milliseconds?
    public
    var authSource:Mongo.Database?
    public
    var authMechanism:Mongo.Authentication?
    public
    var appName:String?

    @inlinable public
    init(user:(name:String, password:String)? = nil,
        discovery:MongoTopology.Discovery,
        defaultauthdb:Mongo.Database? = nil,
        tls:Bool? = nil,
        tlsCAFile:String? = nil,
        connectTimeout:Milliseconds? = nil,
        socketTimeout:Milliseconds? = nil,
        authSource:Mongo.Database? = nil,
        authMechanism:Mongo.Authentication? = nil,
        appName:String? = nil)
    {
        self.user = user
        self.discovery = discovery
        self.defaultauthdb = defaultauthdb
        switch self.discovery
        {
        case .seeded:
            self.tls = tls ?? true
        case .standard:
            self.tls = tls ?? false
        }
        self.tlsCAFile = tlsCAFile
        self.connectTimeout = connectTimeout
        self.socketTimeout = socketTimeout
        self.authSource = authSource
        self.authMechanism = authMechanism
        self.appName = appName
    }
}
// extension MongoConnectionString
// {
//     public
//     init(parsing string:some StringProtocol) throws
//     {
//         if let url:WebURL = .init(string)
//         {
//             try self.init(url: url)
//         }
//         else
//         {
//             throw Mongo.ConnectionStringParsingError.init(url: .init(string))
//         }
//     }
//     public
//     init(url:WebURL) throws 
//     {
//         switch url.scheme
//         {
//         case "mongodb":
//             self.tls = false
//             if  let hosts:[Mongo.Host] = url.hostname?.split(separator: ",")
//                         .map(Mongo.Host.mongodb(parsing:)),
//                     !hosts.isEmpty
//             {
//                 self.hosts = .standard(hosts)
//             }
//             else
//             {
//                 throw Mongo.ConnectionStringError.emptyHostsList
//             }
        
//         case "mongodb+srv":
//             self.tls = true
//             if let name:String = url.hostname
//             {
//                 self.hosts = .srv(.srv(name))
//             }
//             else
//             {
//                 throw Mongo.ConnectionStringError.emptyHostsList
//             }
        
//         case let scheme:
//             throw Mongo.ConnectionStringError.invalidScheme(scheme)
//         }

//         if  let name:String = url.username,
//             let password:String = url.password
//         {
//             self.user = (name: name, password: password)
//         }
//         else
//         {
//             self.user = nil
//         }

//         self.defaultauthdb = url.path.isEmpty ? nil : .init(url.path)

//         self.tlsCAFile = nil
//         self.connectTimeout = nil
//         self.socketTimeout = nil
//         self.authSource = nil
//         self.authMechanism = nil
//         self.appName = nil

//         for (key, value):(String, String) in url.formParams.allKeyValuePairs 
//         {
//             // note: value is case sensitive
//             switch key.lowercased()
//             {
//             case "tls", "ssl":
//                 if let value:Bool = .init(value)
//                 {
//                     self.tls = value
//                 }
            
//             case "tlscafile":
//                 self.tlsCAFile = value
            
//             case "connecttimeoutms":
//                 if let milliseconds:Int = .init(value)
//                 {
//                     self.connectTimeout = .milliseconds(milliseconds)
//                 }
//             case "sockettimeoutms":
//                 if let milliseconds:Int = .init(value)
//                 {
//                     self.socketTimeout = .milliseconds(milliseconds)
//                 }
            
//             case "authsource":
//                 self.authSource = .init(value)
            
//             case "authmechanism":
//                 if let mechanism:Mongo.Authentication = .init(rawValue: value)
//                 {
//                     self.authMechanism = mechanism
//                 }
//                 else
//                 {
//                     throw Mongo.ConnectionStringError.unsupportedAuthenticationMechanism(value)
//                 }
            
//             case "appname":
//                 self.appName = value
            
//             default:
//                 throw Mongo.ConnectionStringError.unsupportedFormParameter(key)
//             }
//         }
//     }
// }
