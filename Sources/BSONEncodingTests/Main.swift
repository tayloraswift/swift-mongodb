import Testing

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        LiteralInference.self,
        TypeInference.self,

        EncodeDocument.self,
        EncodeList.self,
        EncodeString.self,

        FieldDuplication.self,
        FieldElision.self,
    ]
}
