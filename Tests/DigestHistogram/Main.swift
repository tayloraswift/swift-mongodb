//  Based on a C++ implementation from Facebook’s Folly library.
//
//  https://github.com/facebook/folly/blob/main/folly/stats/test/TDigestTest.cpp

import DigestHistogram
import Testing

@main 
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        do
        {
            let tests:TestGroup = tests / "basic"

            var histogram:DigestHistogram = .init(capacity: 100)

            histogram.insert(sorted: (1 ... 100).map(Double.init(_:)))

            tests.expect(histogram.samples ==? 100)
            tests.expect(histogram.sum ==? 5050)
            tests.expect(histogram.mean ==? 50.5)
            tests.expect(histogram.min ==? 1)
            tests.expect(histogram.max ==? 100)

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
            let tests:TestGroup = tests / "insert-single"

            var histogram:DigestHistogram = .init(capacity: 100)

            histogram.insert(1)

            tests.expect(histogram.samples ==? 1)
            tests.expect(histogram.sum ==? 1)
            tests.expect(histogram.mean ==? 1)
            tests.expect(histogram.min ==? 1)
            tests.expect(histogram.max ==? 1)

            tests.expect(histogram.estimate(quantile: 0.000) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.001) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.010) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.500) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.990) ==? 1)
            tests.expect(histogram.estimate(quantile: 0.999) ==? 1)
            tests.expect(histogram.estimate(quantile: 1.000) ==? 1)
        }
        do
        {
            let tests:TestGroup = tests / "insert-multiple"

            var histogram:DigestHistogram = .init(capacity: 100)

            histogram.insert(sorted: (  1 ... 100).map(Double.init(_:)))
            histogram.insert(sorted: (101 ... 200).map(Double.init(_:)))

            tests.expect(histogram.samples ==? 200)
            tests.expect(histogram.sum ==? 20100)
            tests.expect(histogram.mean ==? 100.5)
            tests.expect(histogram.min ==? 1)
            tests.expect(histogram.max ==? 200)

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
            let tests:TestGroup = tests / "insert-many"

            var histogram:DigestHistogram = .init(capacity: 100)

            histogram.insert(sorted: (1 ... 1000).map(Double.init(_:)))

            tests.expect(histogram.samples ==? 1000)
            tests.expect(histogram.sum ==? 500500)
            tests.expect(histogram.mean ==? 500.5)
            tests.expect(histogram.min ==? 1)
            tests.expect(histogram.max ==? 1000)

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

            var histogram:DigestHistogram = .init(capacity: 100)

            histogram.insert((1 ... 100).flatMap
            {
                [.init($0), .init(-$0)]
            })

            tests.expect(histogram.samples ==? 200)
            tests.expect(histogram.sum ==? 0)
            tests.expect(histogram.mean ==? 0)
            tests.expect(histogram.min ==? -100)
            tests.expect(histogram.max ==? 100)

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

            var histogram:DigestHistogram = .init(capacity: 100)

            histogram.insert(sorted: (1 ... 18).map(Double.init(_:)))
            histogram.insert(1_000_000)

            tests.expect(
                true: histogram.estimate(quantile: 0.5) < histogram.estimate(quantile: 0.9))
        }
    }
}
