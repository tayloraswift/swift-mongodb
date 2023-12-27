extension Mongo
{
    @frozen public
    struct WriteConcern:Hashable, Sendable
    {
        public
        let acknowledgement:Acknowledgement

        public
        let journaled:Bool?

        @inlinable internal
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

    @inlinable public static
    func majority(journaled:Bool?) -> Self
    {
        .init(acknowledgement: .mode("majority"), journaled: journaled)
    }

    @inlinable public static
    func custom(mode:String, journaled:Bool? = nil) -> Self
    {
        .init(acknowledgement: .mode(mode), journaled: journaled)
    }

    @inlinable public static
    func acknowledged(by votes:Int, journaled:Bool? = nil) -> Self
    {
        .init(acknowledgement: .acknowledged(by: votes), journaled: journaled)
    }
}
