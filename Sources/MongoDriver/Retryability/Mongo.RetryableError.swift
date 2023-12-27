extension Mongo
{
    public
    typealias RetryableError = _MongoRetryableError
}

/// The name of this protocol is ``Mongo.RetryableError``.
public
protocol _MongoRetryableError:Error
{
    var isRetryable:Bool { get }
}
