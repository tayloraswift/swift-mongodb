extension Mongo
{
    @propertyWrapper
    public final
    class _Boxed<Value>
    {
        public
        var wrappedValue:Value

        @inlinable public
        init(wrappedValue:Value)
        {
            self.wrappedValue = wrappedValue
        }
    }
}
