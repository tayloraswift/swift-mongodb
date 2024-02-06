import BSON

extension BSON.ListEncoder
{
    @inlinable public mutating
    func expr(with encode:(inout Mongo.ExpressionEncoder) -> ())
    {
        self.append { encode(&$0[as: Mongo.ExpressionEncoder.self]) }
    }
}
