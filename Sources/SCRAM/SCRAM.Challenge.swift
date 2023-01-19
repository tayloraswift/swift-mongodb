import Base64

extension SCRAM
{
    @frozen public
    struct Challenge
    {
        public
        let iterations:Int
        public
        let nonce:Nonce
        public
        let salt:[UInt8]

        private
        init(iterations:Int, nonce:Nonce, salt:[UInt8])
        {
            self.iterations = iterations
            self.nonce = nonce
            self.salt = salt
        }
    }
}
extension SCRAM.Challenge
{
    @inlinable public
    func id(password:String) -> CacheIdentifier
    {
        .init(iterations: self.iterations, password: password, salt: self.salt)
    }
}
extension SCRAM.Challenge
{
    public
    init(from message:SCRAM.Message) throws
    {
        var iterations:Int? = nil
        var nonce:String? = nil
        var salt:String? = nil

        for (attribute, value):(SCRAM.Attribute, Substring) in message.fields()
        {
            switch attribute
            {
            case .random:
                nonce = .init(value)
            case .salt:
                salt = .init(value)
            case .iterations:
                iterations = .init(value)
            default:
                continue
            }
        }
        guard let iterations:Int
        else
        {
            throw SCRAM.ChallengeError.attribute(missing: .iterations)
        }
        guard let nonce:String
        else
        {
            throw SCRAM.ChallengeError.attribute(missing: .random)
        }
        guard let salt:String
        else
        {
            throw SCRAM.ChallengeError.attribute(missing: .salt)
        }
        
        self.init(iterations: iterations, nonce: .init(nonce),
            salt: Base64.decode(salt, to: [UInt8].self))
    }
}
