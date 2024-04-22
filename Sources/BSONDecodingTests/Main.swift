import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        DecodeBinary.self,
        DecodeDocument.self,
        DecodeList.self,
        DecodeNumeric.self,
        DecodeString.self,
        DecodeVoid.self,
    ]
}
