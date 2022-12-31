import BSONDecoding

extension MongoConnection
{
    /// An identifier assigned by a server to a driver connection.
    ///
    /// The server uses this identifier as a notion of connection identity,
    /// but from the driver’s perspective, this value is more token-like
    /// than id-like. This is because we do not know what identity the server
    /// has assigned to a driver connection until completing an initial
    /// ``Hello`` handshake, and (in a degenerate case) it can contradict
    /// identifiers sent by the server in later handshakes.
    @frozen public
    struct Token:Hashable, RawRepresentable, Sendable
    {
        public
        let rawValue:Int32

        @inlinable public
        init(rawValue:Int32)
        {
            self.rawValue = rawValue
        }
    }
}
extension MongoConnection.Token:CustomStringConvertible
{
    public
    var description:String
    {
        self.rawValue.description
    }
}
extension MongoConnection.Token:BSONDecodable
{
}
