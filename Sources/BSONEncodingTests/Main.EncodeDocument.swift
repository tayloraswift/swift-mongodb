import BSONEncoding
import Testing_

extension Main
{
    enum EncodeDocument
    {
    }
}
extension Main.EncodeDocument:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        Self.run(tests,
            encoded: .init(BSON.Key.self)
            {
                $0["a"] = [:]
                $0["b"](BSON.Key.self)
                {
                    $0["x"] = 1
                }
                $0["c"](BSON.Key.self)
                {
                    $0["x"] = 1
                    $0["y"] = 2
                }
            },
            literal:
            [
                "a": [:],
                "b": ["x": 1],
                "c": ["x": 1, "y": 2],
            ])
    }
}
