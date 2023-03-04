public
protocol MongoRetryableError:Error
{
    var isRetryable:Bool { get }
}
