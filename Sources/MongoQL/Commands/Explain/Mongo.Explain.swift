import BSON

extension Mongo
{
    @frozen public
    struct Explain<Command>:Sendable where Command:Mongo.Command
    {
        public
        let verbosity:ExplainMode
        public
        let command:Command

        @inlinable public
        init(verbosity:ExplainMode,
            command:Command)
        {
            self.verbosity = verbosity
            self.command = command
        }
    }
}
extension Mongo.Explain:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .explain }

    public
    var fields:BSON.Document
    {
        Self.type(self.command.fields)
        {
            $0["verbosity"] = self.verbosity
        }
    }

    public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ArraySlice<UInt8>>) -> String
    {
        Mongo.ExplainOnly.decode(reply: reply)
    }
}
