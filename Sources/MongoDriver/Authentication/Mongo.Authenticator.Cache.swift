import SCRAM
import SHA2

extension Mongo.Authenticator
{
    final
    actor Cache
    {
        private
        var sha256:[SCRAM.Challenge.CacheIdentifier: SCRAM.ClientResponse<SHA256>.Keys]

        init()
        {
            self.sha256 = [:]
        }
    }
}
extension Mongo.Authenticator.Cache
{
    private
    func store(_ keys:SCRAM.ClientResponse<SHA256>.Keys, for id:SCRAM.Challenge.CacheIdentifier)
    {
        self.sha256[id] = keys
    }
}
extension Mongo.Authenticator.Cache
{
    nonisolated
    func sha256(challenge:SCRAM.Challenge, password:String,
        received:SCRAM.Message,
        sent:SCRAM.Start) async throws -> SCRAM.ClientResponse<SHA256>
    {
        let id:SCRAM.Challenge.CacheIdentifier = challenge.id(password: password)
        // this computation can take a long time, don’t do this on the actor loop.
        // instead we copy to a local and write it back to the cache when we are done.
        var keys:SCRAM.ClientResponse<SHA256>.Keys? = await self.sha256[id]
        let response:SCRAM.ClientResponse<SHA256> = try .init(cached: &keys,
            challenge: challenge,
            password: password,
            received: received,
            sent: sent)
        if  let keys:SCRAM.ClientResponse<SHA256>.Keys
        {
            await self.store(keys, for: id)
        }
        return response
    }
}
