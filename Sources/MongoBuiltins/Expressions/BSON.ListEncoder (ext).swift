import BSON

extension BSON.ListEncoder
{
    @inlinable public mutating
    func expr(with encode:(inout Mongo.Expression) -> ())
    {
        self.append(Mongo.Expression.expr(with: encode))
    }
}
