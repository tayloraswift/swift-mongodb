extension ExpressibleByIntegerLiteral
    where Self:QuantizedDuration, RawValue:_ExpressibleByBuiltinIntegerLiteral
{
    @inlinable public
    init(integerLiteral:RawValue)
    {
        self.init(rawValue: integerLiteral)
    }
}
