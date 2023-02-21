import BSON

extension BSON.Field
{
    @inlinable public mutating
    func frame<Encoder>(_:Encoder.Type = Encoder.self,
        then encode:(inout Encoder) -> ()) where Encoder:BSONEncoder
    {
        self.emit(Encoder.type, frame: BSON.DocumentFrame.self)
        {
            var lens:Encoder = .init(output: $0)
            $0 = .init(preallocated: [])

            encode(&lens)

            $0 = lens.output
        }
    }
}
