extension Mongo
{
    protocol Instant:Sendable
    {
        static
        func < (lhs:Self, rhs:Self) -> Bool
    }
}
extension Mongo.Instant
{
    //  Writing this function in terms of ``AtomicState<Self>`` prevents us
    //  from allocating a new object in the common case where the
    //  max cluster time has not changed.
    func combined(with other:Mongo.AtomicState<Self>?) -> Mongo.AtomicState<Self>
    {
        guard let other:Mongo.AtomicState<Self>
        else
        {
            return .init(self)
        }
        if  other.value < self
        {
            return .init(self)
        }
        else
        {
            return other
        }
    }
    func combined(with other:Self?) -> Self
    {
        guard let other:Self
        else
        {
            return self
        }
        if  other < self
        {
            return self
        }
        else
        {
            return other
        }
    }
    func combine(into value:inout Self?)
    {
        value = self.combined(with: value)
    }
}
