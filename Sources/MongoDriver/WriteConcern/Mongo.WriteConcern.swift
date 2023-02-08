extension Mongo
{
    @frozen public
    struct WriteConcern:Hashable, Sendable
    {
        let acknowledgement:Acknowledgement

        public
        let journaled:Bool?

        private
        init(acknowledgement:Acknowledgement, journaled:Bool? = nil)
        {
            self.acknowledgement = acknowledgement
            self.journaled = journaled
        }
    }
}
extension Mongo.WriteConcern
{
    @inlinable public static
    var majority:Self
    {
        .majority(journaled: nil)
    }
    
    public static
    func majority(journaled:Bool?) -> Self
    {
        .init(acknowledgement: .mode("majority"), journaled: journaled)
    }

    public static
    func custom(mode:String, journaled:Bool? = nil) -> Self
    {
        .init(acknowledgement: .mode(mode), journaled: journaled)
    }

    public static
    func acknowledged(by votes:Int, journaled:Bool? = nil) -> Self
    {
        .init(acknowledgement: .acknowledged(by: votes), journaled: journaled)
    }
}
