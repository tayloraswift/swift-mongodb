extension Mongo
{
    public
    protocol RetryableError:Error
    {
        var isRetryable:Bool { get }
    }
}
