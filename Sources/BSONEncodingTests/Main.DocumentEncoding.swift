import BSONEncoding
import Testing

extension Main
{
    enum DocumentEncoding
    {
    }
}
extension Main.DocumentEncoding:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        Self.run(tests,
            encoded: .init
            {
                $0["a"] = [:]
                $0["b"]
                {
                    $0["x"] = 1
                }
                $0["c"]
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
