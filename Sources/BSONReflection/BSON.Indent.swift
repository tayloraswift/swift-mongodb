import BSON

extension BSON
{
    @frozen public
    struct Indent
    {
        public
        let space:String
        public
        let level:Int

        @inlinable public
        init(space:String, level:Int)
        {
            self.space = space
            self.level = level
        }
    }
}
extension BSON.Indent
{
    @inlinable public static
    func + (self:Self, increment:Int) -> Self
    {
        .init(space: self.space, level: self.level + increment)
    }
}
extension BSON.Indent:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(space: stringLiteral, level: 0)
    }
}
extension BSON.Indent:CustomStringConvertible
{
    @inlinable public
    var description:String { "\n\(String.init(repeating: space, count: level))" }
}
extension BSON.Indent
{
    public
    func print(key:BSON.Key,
        value:BSON.AnyValue<some RandomAccessCollection<UInt8>>,
        to output:inout some TextOutputStream)
    {
        output.write("\(self)$0[\(key)] =")

        let value:String = value.description(indent: self)
        //  Don’t generate lines with trailing whitespace
        if case false = value.first?.isNewline
        {
            output.write(" ")
        }
        output.write(value)
    }
}
