import BSON

extension Mongo
{
    @frozen public
    struct SwitchBranches:Mongo.EncodableList, Sendable
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
