import Base64
import MessageAuthentication

extension SCRAM
{
    /// A client’s response to a SCRAM challenge, authenticating the client.
    @frozen public
    struct ClientResponse<Hash> where Hash:MessageAuthenticationHash
    {
        public
        let message:Message
        @usableFromInline
        let signature:Hash

        @usableFromInline
        init(message:Message, signature:Hash)
        {
            self.message = message
            self.signature = signature
        }
    }
}

extension SCRAM.ClientResponse
{
    @inlinable public
    init(cached:inout Keys?,
        challenge:SCRAM.Challenge,
        password:String,
        received:SCRAM.Message,
        sent:SCRAM.Start) throws
    {
        // server appends its own nonce to the one we generated
        guard challenge.nonce.string.starts(with: sent.nonce.string)
        else
        {
            throw SCRAM.ChallengeError.nonce(challenge.nonce, sent: sent.nonce)
        }

        let prefix:String = "c=biws,r=\(challenge.nonce)"
        let message:String = "\(sent.bare),\(received),\(prefix)"

        let keys:Keys
        if  let cached:Keys
        {
            keys = cached
        }
        else
        {
            // computing the salted key is very slow, so we cache it if possible
            keys = .init(salted: .init(Hash.pbkdf2(
                password: password.utf8,
                salt: challenge.salt,
                iterations: challenge.iterations)))
            cached = keys
        }

        let signature:Hash = .init(authenticating: message.utf8, key: keys.stored)

        let proof:[UInt8] = zip(keys.client, signature).map(^)

        self.init(message: .init("\(prefix),p=\(Base64.encode(proof))"),
            signature: .init(authenticating: message.utf8, key: keys.server))
    }
}
extension SCRAM.ClientResponse
{
    /// Returns `true` if the given server response is consistent with
    /// the server signature computed for this client response.
    @inlinable public
    func verify(_ response:SCRAM.ServerResponse) -> Bool
    {
        self.signature.elementsEqual(response.signature)
    }
}
