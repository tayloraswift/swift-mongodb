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
}
