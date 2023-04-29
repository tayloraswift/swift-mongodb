import BSONEncoding
import BSONDecoding

enum OuterCodingKeys:String
{
    case metadata
}
enum InnerCodingKeys:String
{
    case cLanguageStandard
}

let bson:BSON.Document = .init(OuterCodingKeys.self)
{
    $0[.metadata, using: InnerCodingKeys.self]
    {
        $0[.cLanguageStandard] = 1
    }
}

let decoder:BSON.DocumentDecoder<OuterCodingKeys, [UInt8]> = try .init(parsing: bson)

try decoder[.metadata].decode(using: InnerCodingKeys.self)
{
    _ = try $0[.cLanguageStandard].decode(to: Never?.self)
}
