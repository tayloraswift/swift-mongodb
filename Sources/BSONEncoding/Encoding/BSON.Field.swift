import BSON

extension BSON.Field
{
    @inlinable public mutating
    func encode<Encoder>(as _:Encoder.Type = Encoder.self,
        with encode:(inout Encoder) -> ()) where Encoder:BSONEncoder
    {
        self.emit(Encoder.type, frame: BSON.DocumentFrame.self)
        {
            encode(&$0[as: Encoder.self])
        }
    }
}
