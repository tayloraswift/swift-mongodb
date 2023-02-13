import BSONEncoding
import BSONDecoding

extension Mongo.ServerError
{
    @frozen public
    struct Code:Hashable, RawRepresentable, Sendable
    {
        public
        let rawValue:Int32

        @inlinable public
        init(rawValue:Int32)
        {
            self.rawValue = rawValue
        }
    }
}
extension Mongo.ServerError.Code:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:Int32)
    {
        self.init(rawValue: integerLiteral)
    }
}
extension Mongo.ServerError.Code:CustomStringConvertible
{
    public
    var description:String
    {
        self.rawValue.description
    }
}
extension Mongo.ServerError.Code:BSONDecodable, BSONEncodable
{
}
//  Catalogued from the reference at:
//  https://github.com/mongodb/mongo/blob/master/src/mongo/base/error_codes.yml
extension Mongo.ServerError.Code
{
    var indicatesRetryability:Bool
    {
        switch self.rawValue
        {
        case    6, 7, 89, 91, 134, 189, 262, 317, 358, 384, 9001,
                10107, 11600, 11602, 13435, 13436, 50915:
            return true
        case _:
            return false
        }
    }
    var indicatesInterruption:Bool
    {
        switch self.rawValue
        {
        case    24, 50, 237, 262, 279, 281, 282, 290, 355, 11600, 11601, 11602, 46841:
            return true
        case _:
            return false
        }
    }
    var indicatesTimeLimitExceeded:Bool
    {
        switch self.rawValue
        {
        case    50, 202, 262, 290:
            return true
        case _:
            return false
        }
    }
    var indicatesNotPrimary:Bool
    {
        switch self.rawValue
        {
        case    189, 10107, 11602, 13435, 13436:
            return true
        case _:
            return false
        }
    }
}
