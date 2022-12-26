import MongoChannel
import MongoTopology

extension MongoTopology
{
    subscript(selector:Mongo.SessionMediumSelector) -> MongoChannel?
    {
        switch selector
        {
        case .master:   return self.master
        case .any:      return self.any
        }
    }
}
