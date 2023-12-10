import BSONEncoding
import Testing

extension Main
{
    enum FieldElision
    {
    }
}
extension Main.FieldElision:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let _:BSON.Document = [:]

        Self.run(tests / "null",
            encoded: .init
            {
                $0["elided"] = nil as Never??
                $0["inhabited"] = (nil as Never?) as Never??
            },
            literal:
            [
                "inhabited": .null,
            ])

        Self.run(tests / "integer",
            encoded: .init
            {
                $0["elided"] = nil as Int?
                $0["inhabited"] = 5
            },
            literal:
            [
                "inhabited": 5,
            ])

        Self.run(tests / "optional",
            encoded: .init
            {
                $0["elided"] = nil as Int??
                $0["inhabited"] = (5 as Int?) as Int??
                $0["uninhabited"] = (nil as Int?) as Int??
            },
            literal:
            [
                "inhabited": 5,
                "uninhabited": .null,
            ])
    }
}