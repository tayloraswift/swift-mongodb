import Testing

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        LiteralInference.self,
        TypeInference.self,

        ArrayEncoding.self,
        DocumentEncoding.self,
        StringEncoding.self,

        FieldDuplication.self,
        FieldElision.self,
    ]
}
