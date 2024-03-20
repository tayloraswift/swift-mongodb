extension BSON
{
    public
    protocol Encoder
    {
        init(_:consuming Output)

        consuming
        func move() -> Output

        static
        var type:AnyType { get }
    }
}
