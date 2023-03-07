extension Mongo
{
    /// An ordered set of hosts. Every host in this collection
    /// is statically guaranteed to be unique, and there will
    /// always be at least one host.
    ///
    /// The uniqueness guarantee is important for preventing
    /// the service monitoring system from creating duplicate
    /// monitoring tasks.
    public
    struct Seedlist:Sendable
    {
        @usableFromInline internal
        let elements:[Host]

        @inlinable public
        init(host:Host)
        {
            self.elements = [host]
        }
        @inlinable internal
        init(uniqueHosts:[Host])
        {
            if uniqueHosts.isEmpty
            {
                fatalError("Seedlist cannot be empty.")
            }

            self.elements = uniqueHosts
        }
    }
}
extension Mongo.Seedlist
{
    @inlinable public
    init(hosts:some Sequence<Mongo.Host>)
    {
        var unique:[Mongo.Host] = []
        var seen:Set<Mongo.Host> = []

        unique.reserveCapacity(hosts.underestimatedCount)
        seen.reserveCapacity(hosts.underestimatedCount)

        for host:Mongo.Host in hosts
        {
            if case nil = seen.update(with: host)
            {
                unique.append(host)
            }
        }

        self.init(uniqueHosts: unique)
    }
    @inlinable public
    init(hostnames:some Sequence<String>)
    {
        self.init(hosts: hostnames.lazy.map { .init(name: $0) })
    }
}
extension Mongo.Seedlist:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:String...)
    {
        self.init(hostnames: arrayLiteral)
    }
}
extension Mongo.Seedlist:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(String, Int?)...)
    {
        self.init(hosts: dictionaryLiteral.lazy.map { .init(name: $0.0, port: $0.1) })
    }
}

extension Mongo.Seedlist:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.elements.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.elements.endIndex
    }
    @inlinable public
    subscript(index:Int) -> Mongo.Host
    {
        self.elements[index]
    }
}
extension Mongo.Seedlist
{
    /// Returns a new seedlist containing the elements at specified indices
    /// in the original seedlist. Calling this functor is faster than
    /// rebuilding a new seedlist from a slice view.
    ///
    /// >   Complexity: O(*n*), where *n* is the length of the seedlist.
    @inlinable public
    func callAsFunction(_ range:some RangeExpression<Int>) -> Self
    {
        .init(uniqueHosts: [Mongo.Host].init(self.elements[range]))
    }
}
extension Mongo.Seedlist
{
    func dictionary<Value>(repeating value:Value) -> [Mongo.Host: Value]
    {
        .init(uniqueKeysWithValues: self.lazy.map { ($0, value) })
    }
}
