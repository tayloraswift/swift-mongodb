import BSON

extension BSON.Field
{
    @inlinable public mutating
    func frame<Lens>(_:Lens.Type = Lens.self,
        then encode:(inout Lens) -> ()) where Lens:BSONLens
    {
        self.frame(Lens.type)
        {
            var lens:Lens = .init(output: $0)
            $0 = .init(preallocated: [])

            encode(&lens)

            $0 = lens.output
        }
    }
}
