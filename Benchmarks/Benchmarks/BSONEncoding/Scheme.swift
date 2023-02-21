import BSONEncoding

extension Date
{
    struct Year:RawRepresentable
    {
        let rawValue:Int32

        init(rawValue:Int32)
        {
            self.rawValue = rawValue
        }
    }
}
extension Date.Year
{
    var leap:Int
    {
        self.rawValue %   4 != 0 ? 0 : 
        self.rawValue % 100 != 0 ? 1 :
        self.rawValue % 400 != 0 ? 0 : 1
    }

    func days(in month:Date.Month) -> Int
    {
        switch month
        {
        case .january:      return 31
        case .february:     return 28 + self.leap
        case .march:        return 31
        case .april:        return 30
        case .may:          return 31
        case .june:         return 30
        case .july:         return 31
        case .august:       return 31
        case .september:    return 30
        case .october:      return 31
        case .november:     return 30
        case .december:     return 31
        }
    }
}
extension Date.Year:Strideable
{
    func advanced(by step:Int32) -> Self
    {
        .init(rawValue: self.rawValue + step)
    }
    func distance(to end:Self) -> Int32
    {
        end.rawValue - self.rawValue
    }
}
extension Date.Year:ExpressibleByIntegerLiteral
{
    init(integerLiteral:Int32)
    {
        self.init(rawValue: integerLiteral)
    }
}
extension Date.Year:CustomStringConvertible
{
    var description:String
    {
        self.rawValue.description
    }
}
extension Date.Year:BSONEncodable
{
}

extension Date
{
    enum Month:Int32, CaseIterable
    {
        case january = 1
        case february
        case march
        case april
        case may
        case june
        case july
        case august
        case september
        case october
        case november
        case december
    }
}
extension Date.Month:BSONEncodable
{
}

extension Date
{
    enum Weekday:String, CaseIterable
    {
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
    }
}
extension Date.Weekday:BSONEncodable
{
}

struct Date
{
    let year:Year
    let month:Month
    let day:Int
    let weekday:Weekday
    var comment:String

    init(year:Year, month:Month, day:Int, weekday:Weekday)
    {
        self.year = year
        self.month = month
        self.day = day
        self.weekday = weekday
        self.comment = ""
        self.comment = self.description
    }
}
extension Date:CustomStringConvertible
{
    var description:String
    {
        "\(self.weekday) \(self.month) \(self.day), \(self.year)"
    }
}
extension Date:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson["year"] = self.year
        bson["month"] = self.month
        bson["day"] = self.day
        bson["weekday"] = self.weekday
        bson["comment"] = self.comment
    }
}
