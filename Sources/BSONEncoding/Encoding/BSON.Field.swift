import BSON

extension BSON.Field
{
    @inlinable public mutating
    func with<Encoder>(_:Encoder.Type,
        do encode:(inout Encoder) -> ()) where Encoder:BSONEncoder
    {
        self.emit(Encoder.type, frame: BSON.DocumentFrame.self)
        {
            $0.with(Encoder.self, do: encode)
        }
    }
}
