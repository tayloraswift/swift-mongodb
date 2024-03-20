extension BSON
{
    public
    protocol Decoder
    {
        init(parsing bson:borrowing AnyValue) throws
    }
}
