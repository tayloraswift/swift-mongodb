import BSONEncoding
import Testing_

extension Main
{
    enum FieldDuplication
    {
    }
}
extension Main.FieldDuplication:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        Self.run(tests / "integer",
            encoded: .init(BSON.Key.self)
            {
                $0["inhabited"] = 5
                $0["uninhabited"] = nil as Never??
                $0["inhabited"] = 7
                $0["uninhabited"] = nil as Never??
            },
            literal:
            [
                "inhabited": 5,
                "inhabited": 7,
            ])
    }
}
