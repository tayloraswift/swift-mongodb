import UnixTime

extension BSON
{
    @available(*, deprecated, renamed: "UnixMillisecond")
    public
    typealias Millisecond = UnixMillisecond
}
extension UnixMillisecond
{
    @available(*, unavailable, renamed: "init(index:)")
    @inlinable public
    init(_ index:Int64) { self.init(index: index) }

    @available(*, unavailable, renamed: "index")
    @inlinable public
    var value:Int64 { self.index }
}
@available(*, unavailable)
extension UnixMillisecond:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:Int64) { self.init(index: integerLiteral) }
}
