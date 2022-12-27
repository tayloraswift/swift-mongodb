import MongoWire

extension Mongo
{
    public
    struct VersionRequirementError:Equatable, Error
    {
        public
        let wireVersions:ClosedRange<MongoWire>

        init(invalid:ClosedRange<MongoWire>)
        {
            self.wireVersions = invalid
        }
    }
}
extension Mongo.VersionRequirementError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        driver requires mongo wire version >= 17, but server only supports\
        \(self.wireVersions.lowerBound) ... \(self.wireVersions.upperBound)
        """
    }
}
