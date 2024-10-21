import BSONEncoding
import Testing_

extension Main
{
    enum EncodeList
    {
    }
}
extension Main.EncodeList:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        Self.run(tests,
            encoded: .init(BSON.Key.self)
            {
                $0["a"] = [] as [Never]
                $0["b"] = [1]
                $0["c"](Int.self)
                {
                    $0[+] = 1
                    $0[+] = "x"
                    $0[+] = 5.5
                }
            },
            literal:
            [
                "a": [],
                "b": [1],
                "c": [1, "x", 5.5],
            ])
    }
}
