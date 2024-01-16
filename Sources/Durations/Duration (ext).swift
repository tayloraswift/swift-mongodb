extension Duration
{
    @inlinable public static
    func minutes(_ minutes:Minutes) -> Self
    {
        .seconds(minutes.seconds)
    }
    @inlinable public static
    func seconds(_ seconds:Seconds) -> Self
    {
        .seconds(seconds.rawValue)
    }
    @inlinable public static
    func milliseconds(_ milliseconds:Milliseconds) -> Self
    {
        .milliseconds(milliseconds.rawValue)
    }
    @inlinable public static
    func microseconds(_ microseconds:Microseconds) -> Self
    {
        .microseconds(microseconds.rawValue)
    }
    @inlinable public static
    func nanoseconds(_ nanoseconds:Nanoseconds) -> Self
    {
        .nanoseconds(nanoseconds.rawValue)
    }
}
