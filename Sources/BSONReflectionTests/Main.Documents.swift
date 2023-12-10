import BSON
import BSONReflection
import Testing

extension Main
{
    enum Documents
    {
    }
}
extension Main.Documents:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let document:BSON.Document = .init
        {
            $0["_id"] = 0x1111_2222_3333_4444_5555_6666 as BSON.Identifier
            $0["facility"] = "Recreation and Activities Center"

            $0["logo"] = BSON.BinaryView<[UInt8]>.init(
                subtype: .generic,
                slice: [1, 2, 3, 4, 5])

            $0["incidents"] = 145
            $0["averageRating"] = 2.76
            $0["supervisors"] = ["Barbie", "Midge", "Raquelle"]
            $0["notes"] = [] as [Never]
            $0["campaigns"] = [:]
            $0["complaints"]
            {
                $0.append
                {
                    $0["_id"] = 0x4455_6677_8899_AABB
                    $0["type"] = "property damage"
                    $0["supervisor"] = "Raquelle"
                    $0["status"] = "open"
                    $0["date"]
                    {
                        $0["Y"] = 2022
                        $0["M"] = 12
                        $0["D"] = 31
                    }
                }
                $0.append
                {
                    $0["_id"] = 0x4455_6677_8899_AABC
                    $0["type"] = "sexual assault"
                    $0["supervisor"] = "Midge"
                    $0["status"] = "open"
                    $0["rpi"] = true
                    $0["date"]
                    {
                        $0["Y"] = 2023
                        $0["M"] = 1
                        $0["D"] = 1
                    }
                }
                $0.append
                {
                    $0["_id"] = 0x4455_6677_8899_AABD
                    $0["type"] = "property theft"
                    $0["supervisor"] = "Barbie"
                    $0["status"] = "closed"
                    $0["date"]
                    {
                        $0["Y"] = 2023
                        $0["M"] = 1
                        $0["D"] = 4
                    }
                }
                $0.append
                {
                    $0["_id"] = 0x4455_6677_8899_AABE
                    $0["type"] = "property damage"
                    $0["supervisor"] = "Midge"
                    $0["status"] = "open"
                    $0["date"]
                    {
                        $0["Y"] = 2023
                        $0["M"] = 1
                        $0["D"] = 16
                    }
                }
                $0.append
                {
                    $0["_id"] = 0x4455_6677_8899_AABF
                    $0["type"] = "assault"
                    $0["supervisor"] = "Raquelle"
                    $0["status"] = "closed"
                    $0["rpi"] = false
                    $0["date"]
                    {
                        $0["Y"] = 2023
                        $0["M"] = 1
                        $0["D"] = 22
                    }
                }
                $0.append
                {
                    $0["_id"] = 0x4455_6677_8899_AAC0
                    $0["type"] = "guest expulsion"
                    $0["supervisor"] = "Barbie"
                    $0["status"] = "closed"
                    $0["rpi"] = true
                    $0["date"]
                    {
                        $0["Y"] = 2023
                        $0["M"] = 2
                        $0["D"] = 14
                    }
                }
                $0.append
                {
                    $0["_id"] = 0x4455_6677_8899_AAC1
                    $0["type"] = "sexual assault"
                    $0["supervisor"] = "Barbie"
                    $0["status"] = "open"
                    $0["rpi"] = false
                    $0["date"]
                    {
                        $0["Y"] = 2023
                        $0["M"] = 2
                        $0["D"] = 14
                    }
                }
            }
        }
        let value:BSON.AnyValue<[UInt8]> = .document(.init(document))
        let expected:String =
        """
        {
            $0[_id] = 0x11112222_33334444_55556666
            $0[facility] = "Recreation and Activities Center"
            $0[logo] = { binary data, type 0 }
            $0[incidents] = 145
            $0[averageRating] = 2.76
            $0[supervisors] =
            {
                $0[0] = "Barbie"
                $0[1] = "Midge"
                $0[2] = "Raquelle"
            }
            $0[notes] = []
            $0[campaigns] = [:]
            $0[complaints] =
            {
                $0[0] =
                {
                    $0[_id] = 4923954431178418875 as Int64
                    $0[type] = "property damage"
                    $0[supervisor] = "Raquelle"
                    $0[status] = "open"
                    $0[date] =
                    {
                        $0[Y] = 2022
                        $0[M] = 12
                        $0[D] = 31
                    }
                }
                $0[1] =
                {
                    $0[_id] = 4923954431178418876 as Int64
                    $0[type] = "sexual assault"
                    $0[supervisor] = "Midge"
                    $0[status] = "open"
                    $0[rpi] = true
                    $0[date] =
                    {
                        $0[Y] = 2023
                        $0[M] = 1
                        $0[D] = 1
                    }
                }
                $0[2] =
                {
                    $0[_id] = 4923954431178418877 as Int64
                    $0[type] = "property theft"
                    $0[supervisor] = "Barbie"
                    $0[status] = "closed"
                    $0[date] =
                    {
                        $0[Y] = 2023
                        $0[M] = 1
                        $0[D] = 4
                    }
                }
                $0[3] =
                {
                    $0[_id] = 4923954431178418878 as Int64
                    $0[type] = "property damage"
                    $0[supervisor] = "Midge"
                    $0[status] = "open"
                    $0[date] =
                    {
                        $0[Y] = 2023
                        $0[M] = 1
                        $0[D] = 16
                    }
                }
                $0[4] =
                {
                    $0[_id] = 4923954431178418879 as Int64
                    $0[type] = "assault"
                    $0[supervisor] = "Raquelle"
                    $0[status] = "closed"
                    $0[rpi] = false
                    $0[date] =
                    {
                        $0[Y] = 2023
                        $0[M] = 1
                        $0[D] = 22
                    }
                }
                $0[5] =
                {
                    $0[_id] = 4923954431178418880 as Int64
                    $0[type] = "guest expulsion"
                    $0[supervisor] = "Barbie"
                    $0[status] = "closed"
                    $0[rpi] = true
                    $0[date] =
                    {
                        $0[Y] = 2023
                        $0[M] = 2
                        $0[D] = 14
                    }
                }
                $0[6] =
                {
                    $0[_id] = 4923954431178418881 as Int64
                    $0[type] = "sexual assault"
                    $0[supervisor] = "Barbie"
                    $0[status] = "open"
                    $0[rpi] = false
                    $0[date] =
                    {
                        $0[Y] = 2023
                        $0[M] = 2
                        $0[D] = 14
                    }
                }
            }
        }
        """

        var l:Int = 0
        for (line, expected):(Substring, Substring) in zip(
            "\(value)".split(whereSeparator: \.isNewline),
            expected.split(whereSeparator: \.isNewline))
        {
            l += 1
            (tests / "Line\(l)")?.expect(line ==? expected)
        }
    }
}
