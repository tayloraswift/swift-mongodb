import BSON

extension Mongo
{
    @frozen public
    struct SwitchBranches:MongoListDSL, Sendable
    {
        public
        var bson:BSON.List

        @inlinable public
        init(_ bson:BSON.List)
        {
            self.bson = bson
        }
    }
}
