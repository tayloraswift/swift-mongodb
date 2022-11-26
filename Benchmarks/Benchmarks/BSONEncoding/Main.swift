import BenchmarkSupport
import BSONEncoding

@main
extension BenchmarkRunner
{
}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks()
{
    // generate dates
    var dates:[Date] = []
    var index:Int = 4
    for year:Date.Year in 1492 ... 2022
    {
        for month:Date.Month in Date.Month.allCases
        {
            for day:Int in 1 ... year.days(in: month)
            {
                let date:Date = .init(year: year, month: month, day: day,
                    weekday: Date.Weekday.allCases[index % 7])
                dates.append(date)
                index += 1
            }
        }
    }
    print("generated \(dates.count) dates")
    Benchmark.init("dates",
        metrics: [.throughput, .mallocCountSmall, .mallocCountLarge, .cpuUser, .cpuTotal],
        timeUnits: .microseconds,
        desiredDuration: .seconds(10))
    {
        benchmark in
        
        for _:Int in 0 ..< 5
        {
            blackHole(encode(dates: dates))
        }
    }
}

@inline(never)
func encode(dates:[Date]) -> [BSON.Fields]
{
    dates.map { .init(with: $0.encode(to:)) }
}
