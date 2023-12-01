import BSONDecoding
import BSONEncoding

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
            true
        case _:
            false
        }
    }
    var indicatesInterruption:Bool
    {
        switch self.rawValue
        {
        case    24, 50, 237, 262, 279, 281, 282, 290, 355, 11600, 11601, 11602, 46841:
            true
        case _:
            false
        }
    }
    /// A command was timed-out by the server, most likely according to `maxTimeMS`
    /// (``MaxTime``).
    ///
    /// Server-side timeouts are efficient, because the driver can reuse the connection used to
    /// run the original command to run another command.
    public
    var indicatesTimeLimitExceeded:Bool
    {
        switch self.rawValue
        {
        case    50, 202, 262, 290:
            true
        case _:
            false
        }
    }
    var indicatesNotPrimary:Bool
    {
        switch self.rawValue
        {
        case    189, 10107, 11602, 13435, 13436:
            true
        case _:
            false
        }
    }
}
