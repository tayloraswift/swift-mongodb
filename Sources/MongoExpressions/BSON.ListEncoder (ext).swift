import BSONEncoding

extension BSON.ListEncoder
{
    @inlinable public mutating
    func expr(with encode:(inout MongoExpression) -> ())
    {
        self.append(MongoExpression.expr(with: encode))
    }
}
