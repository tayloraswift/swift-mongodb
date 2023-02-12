//  Based on a C++ implementation from Facebook’s Folly library.
//
//  https://github.com/facebook/folly/blob/main/folly/stats/test/TDigestTest.cpp

import OnlineCDF
import Testing

@main 
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        do
        {
            let tests:TestGroup = tests / "insert-one"

            let histogram:OnlineCDF = .init(resolution: 100, seed: 2)

            tests.expect(histogram.weight ==? 1)
            tests.expect(histogram.mean ==? 2)
            tests.expect(histogram.min ==? 2)
            tests.expect(histogram.max ==? 2)
            tests.expect(histogram.sum ==? 2)

            tests.expect(histogram.estimate(quantile: 0.000) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.001) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.010) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.500) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.990) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.999) ==? 2)
            tests.expect(histogram.estimate(quantile: 1.000) ==? 2)
        }
        do
        {
            let tests:TestGroup = tests / "insert-many"

            var histogram:OnlineCDF = .init(resolution: 100, seed: 1)
            for sample:Int in 2 ... 100
            {
                histogram.insert(.init(sample))
            }

            tests.expect(histogram.weight ==? 100)
            tests.expect(histogram.mean ==? 50.5)
            tests.expect(histogram.min ==? 1)
            tests.expect(histogram.max ==? 100)
            tests.expect(histogram.sum ==? 5050)

            tests.expect(histogram.estimate(quantile: 0.000) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.001) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.010) ==? 1.5)
            tests.expect(histogram.estimate(quantile: 0.500) ==? 50.375)
            tests.expect(histogram.estimate(quantile: 0.990) ==? 99.5)
            tests.expect(histogram.estimate(quantile: 0.999) ==? 100)
            tests.expect(histogram.estimate(quantile: 1.000) ==? 100)
        }
        do
        {
            let tests:TestGroup = tests / "insert-one-batch"

            let histogram:OnlineCDF = .init(resolution: 100,
                sorted: (1 ... 100).map(Double.init(_:)))

            tests.expect(histogram.weight ==? 100)
            tests.expect(histogram.mean ==? 50.5)
            tests.expect(histogram.min ==? 1)
            tests.expect(histogram.max ==? 100)
            tests.expect(histogram.sum ==? 5050)

            tests.expect(histogram.estimate(quantile: 0.000) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.001) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.010) ==? 1.5)
            tests.expect(histogram.estimate(quantile: 0.500) ==? 50.375)
            tests.expect(histogram.estimate(quantile: 0.990) ==? 99.5)
            tests.expect(histogram.estimate(quantile: 0.999) ==? 100)
            tests.expect(histogram.estimate(quantile: 1.000) ==? 100)
        }
        do
        {
            let tests:TestGroup = tests / "insert-many-batches"

            var histogram:OnlineCDF = .init(resolution: 100,
                sorted: (  1 ... 100).map(Double.init(_:)))
            histogram.insert(
                sorted: (101 ... 200).map(Double.init(_:)))

            tests.expect(histogram.weight ==? 200)
            tests.expect(histogram.mean ==? 100.5)
            tests.expect(histogram.min ==? 1)
            tests.expect(histogram.max ==? 200)
            tests.expect(histogram.sum ==? 20100)

            tests.expect(histogram.estimate(quantile: 0.000) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.001) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.010) ==? 2.5)
            tests.expect(histogram.estimate(quantile: 0.500) ==? 100.25)
            tests.expect(histogram.estimate(quantile: 0.990) ==? 198.5)
            tests.expect(histogram.estimate(quantile: 0.999) ==? 200)
            tests.expect(histogram.estimate(quantile: 1.000) ==? 200)
        }
        do
        {
            let tests:TestGroup = tests / "large"

            let histogram:OnlineCDF = .init(resolution: 100,
                sorted: (1 ... 1000).map(Double.init(_:)))

            tests.expect(histogram.weight ==? 1000)
            tests.expect(histogram.mean ==? 500.5)
            tests.expect(histogram.min ==? 1)
            tests.expect(histogram.max ==? 1000)
            tests.expect(histogram.sum ==? 500500)

            tests.expect(histogram.estimate(quantile: 0.000) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.001) ==? 1.5)
            tests.expect(histogram.estimate(quantile: 0.010) ==? 10.5)
            tests.expect(histogram.estimate(quantile: 0.500) ==? 500.25)
            tests.expect(histogram.estimate(quantile: 0.990) ==? 990.25)
            tests.expect(histogram.estimate(quantile: 0.999) ==? 999.5)
            tests.expect(histogram.estimate(quantile: 1.000) ==? 1000)
        }
        do
        {
            let tests:TestGroup = tests / "signed"

            let histogram:OnlineCDF = .init(resolution: 100,
                seeds: (1 ... 100).flatMap
                {
                    [.init($0), .init(-$0)]
                })

            tests.expect(histogram.weight ==? 200)
            tests.expect(histogram.mean ==? 0)
            tests.expect(histogram.min ==? -100)
            tests.expect(histogram.max ==? 100)
            tests.expect(histogram.sum ==? 0)

            tests.expect(histogram.estimate(quantile: 0.000) ==? -100)
            tests.expect(histogram.estimate(quantile: 0.001) ==? -100)
            tests.expect(histogram.estimate(quantile: 0.010) ==? -98.5)
            tests.expect(histogram.estimate(quantile: 0.990) ==?  98.5)
            tests.expect(histogram.estimate(quantile: 0.999) ==?  100)
            tests.expect(histogram.estimate(quantile: 1.000) ==?  100)
        }
        do
        {
            let tests:TestGroup = tests / "outliers"

            var histogram:OnlineCDF = .init(resolution: 100,
                sorted: (1 ..< 100).map(Double.init(_:)))
            histogram.insert(1_000_000)

            tests.expect(histogram.estimate(quantile: 0.000) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.001) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.010) ==? 1.5)
            tests.expect(histogram.estimate(quantile: 0.500) ==? 50.375)
            tests.expect(histogram.estimate(quantile: 0.900) ==? 90.5)
            tests.expect(histogram.estimate(quantile: 1.000) ==? 1_000_000)
        }
        do
        {
            let tests:TestGroup = tests / "steps-balanced"

            var histogram:OnlineCDF = .init(resolution: 100,
                sorted: [Double].init(repeatElement(1, count: 100)))
            histogram.insert(
                sorted: [Double].init(repeatElement(3, count: 100)))
            histogram.insert(
                sorted: [Double].init(repeatElement(2, count: 100)))

            tests.expect(histogram.estimate(quantile: 0.0) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.1) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.2) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.3) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.4) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.5) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.6) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.7) ==? 3)
            tests.expect(histogram.estimate(quantile: 0.8) ==? 3)
            tests.expect(histogram.estimate(quantile: 0.9) ==? 3)
            tests.expect(histogram.estimate(quantile: 1.0) ==? 3)
        }
        do
        {
            let tests:TestGroup = tests / "steps-unbalanced"

            var histogram:OnlineCDF = .init(resolution: 100,
                sorted: [Double].init(repeatElement(2, count: 50)))
            histogram.insert(
                sorted: [Double].init(repeatElement(1, count: 100)))
            histogram.insert(
                sorted: [Double].init(repeatElement(3, count: 50)))

            tests.expect(histogram.estimate(quantile: 0.0) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.1) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.2) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.3) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.4) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.5) ==? 1.5)
            tests.expect(histogram.estimate(quantile: 0.6) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.7) ==? 2)
            tests.expect(histogram.estimate(quantile: 0.8) ==? 3)
            tests.expect(histogram.estimate(quantile: 0.9) ==? 3)
            tests.expect(histogram.estimate(quantile: 1.0) ==? 3)
        }
    }
}
