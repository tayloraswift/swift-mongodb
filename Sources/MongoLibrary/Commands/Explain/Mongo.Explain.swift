import BSON
import MongoDriver
import NIOCore

extension Mongo
{
    @frozen public
    struct Explain<Command>:Sendable where Command:MongoCommand
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
extension Mongo.Explain:MongoImplicitSessionCommand, MongoCommand
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
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) -> String
    {
        Mongo.ExplainOnly.decode(reply: reply)
    }
}
