import BSONEncoding
import Testing_

extension Main
{
    enum EncodeString
    {
    }
}
extension Main.EncodeString:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        Self.run(tests,
            encoded: .init(BSON.Key.self)
            {
                $0["a"] = ""
                $0["b"] = "foo"
                $0["c"] = "foo\u{0}"
            },
            literal:
            [
                "a": "",
                "b": "foo",
                "c": "foo\u{0}",
            ])
    }
}
