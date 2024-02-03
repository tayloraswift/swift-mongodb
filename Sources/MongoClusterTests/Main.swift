import Testing

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        ReplicaSets.self,
    ]
}
