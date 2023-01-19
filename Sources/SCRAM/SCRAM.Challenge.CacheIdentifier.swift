extension SCRAM.Challenge
{
    @frozen public
    struct CacheIdentifier:Hashable, Sendable
    {
        public
        let iterations:Int
        public
        let password:String
        public
        let salt:[UInt8]

        @inlinable public
        init(iterations:Int, password:String, salt:[UInt8])
        {
            self.iterations = iterations
            self.password = password
            self.salt = salt
        }
    }
}
