extension BSON
{
    @frozen public
    struct Elements:Sendable
    {
        public
        var output:BSON.Output<[UInt8]>
        public
        var counter:Int

        @inlinable public
        init(output:BSON.Output<[UInt8]> = .init(capacity: 0))
        {
            self.output = output
            self.counter = 0
        }
    }
}
extension BSON.Elements
{
    @inlinable public mutating
    func append(with serialize:(inout BSON.Field) -> ())
    {
        self.output.with(key: self.counter.description, do: serialize)
        self.counter += 1
    }
    @inlinable public
    var isEmpty:Bool
    {
        self.output.destination.isEmpty
    }
}
extension BSON.Elements
{
    /// Creates an empty encoding view and initializes it with the given closure.
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }
}
