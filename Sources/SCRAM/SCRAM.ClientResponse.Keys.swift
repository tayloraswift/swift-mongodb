import MessageAuthentication

extension SCRAM.ClientResponse
{
    @frozen public
    struct Keys
    {
        public
        let server:Hash
        public
        let client:Hash
        public
        let stored:Hash

        @inlinable public
        init(server:Hash, client:Hash, stored:Hash)
        {
            self.server = server
            self.client = client
            self.stored = stored
        }
    }
}
extension SCRAM.ClientResponse.Keys:Sendable where Hash:Sendable
{
}
extension SCRAM.ClientResponse.Keys
{
    @inlinable public
    init(server:Hash, client:Hash)
    {
        self.init(server: server, client: client, stored: .init(hashing: client))
    }
    @inlinable public
    init(salted:MessageAuthenticationKey<Hash>)
    {
        self.init(
            server: salted.authenticate("Server Key".utf8),
            client: salted.authenticate("Client Key".utf8))
    }
}
