//  Based on a C++ implementation from Facebook’s Folly library.
//
//  https://github.com/facebook/folly/blob/main/folly/stats/test/TDigestTest.cpp

import OnlineCDF
import Testing

@Suite
struct Histograms
{
    @Test
    static func InsertOne()
    {
        let histogram:OnlineCDF = .init(resolution: 100, seed: 2)

        #expect(histogram.weight == 1)
        #expect(histogram.mean == 2)
        #expect(histogram.min == 2)
        #expect(histogram.max == 2)
        #expect(histogram.sum == 2)

        #expect(histogram.estimate(quantile: 0.000) == 2)
        #expect(histogram.estimate(quantile: 0.001) == 2)
        #expect(histogram.estimate(quantile: 0.010) == 2)
        #expect(histogram.estimate(quantile: 0.500) == 2)
        #expect(histogram.estimate(quantile: 0.990) == 2)
        #expect(histogram.estimate(quantile: 0.999) == 2)
        #expect(histogram.estimate(quantile: 1.000) == 2)
    }
    @Test
    static func InsertMany()
    {
        var histogram:OnlineCDF = .init(resolution: 100, seed: 1)
        for sample:Int in 2 ... 100
        {
            histogram.insert(.init(sample))
        }

        #expect(histogram.weight == 100)
        #expect(histogram.mean == 50.5)
        #expect(histogram.min == 1)
        #expect(histogram.max == 100)
        #expect(histogram.sum == 5050)

        #expect(histogram.estimate(quantile: 0.000) == 1)
        #expect(histogram.estimate(quantile: 0.001) == 1)
        #expect(histogram.estimate(quantile: 0.010) == 1.5)
        #expect(histogram.estimate(quantile: 0.500) == 50.375)
        #expect(histogram.estimate(quantile: 0.990) == 99.5)
        #expect(histogram.estimate(quantile: 0.999) == 100)
        #expect(histogram.estimate(quantile: 1.000) == 100)
    }
    @Test
    static func InsertOneBatch()
    {
        let histogram:OnlineCDF = .init(resolution: 100,
            sorted: (1 ... 100).map(Double.init(_:)))

        #expect(histogram.weight == 100)
        #expect(histogram.mean == 50.5)
        #expect(histogram.min == 1)
        #expect(histogram.max == 100)
        #expect(histogram.sum == 5050)

        #expect(histogram.estimate(quantile: 0.000) == 1)
        #expect(histogram.estimate(quantile: 0.001) == 1)
        #expect(histogram.estimate(quantile: 0.010) == 1.5)
        #expect(histogram.estimate(quantile: 0.500) == 50.375)
        #expect(histogram.estimate(quantile: 0.990) == 99.5)
        #expect(histogram.estimate(quantile: 0.999) == 100)
        #expect(histogram.estimate(quantile: 1.000) == 100)
    }
    @Test
    static func InsertManyBatches()
    {
        var histogram:OnlineCDF = .init(resolution: 100,
            sorted: (  1 ... 100).map(Double.init(_:)))
        histogram.insert(
            sorted: (101 ... 200).map(Double.init(_:)))

        #expect(histogram.weight == 200)
        #expect(histogram.mean == 100.5)
        #expect(histogram.min == 1)
        #expect(histogram.max == 200)
        #expect(histogram.sum == 20100)

        #expect(histogram.estimate(quantile: 0.000) == 1)
        #expect(histogram.estimate(quantile: 0.001) == 1)
        #expect(histogram.estimate(quantile: 0.010) == 2.5)
        #expect(histogram.estimate(quantile: 0.500) == 100.25)
        #expect(histogram.estimate(quantile: 0.990) == 198.5)
        #expect(histogram.estimate(quantile: 0.999) == 200)
        #expect(histogram.estimate(quantile: 1.000) == 200)
    }
    @Test
    static func Large()
    {
        let histogram:OnlineCDF = .init(resolution: 100,
            sorted: (1 ... 1000).map(Double.init(_:)))

        #expect(histogram.weight == 1000)
        #expect(histogram.mean == 500.5)
        #expect(histogram.min == 1)
        #expect(histogram.max == 1000)
        #expect(histogram.sum == 500500)

        #expect(histogram.estimate(quantile: 0.000) == 1)
        #expect(histogram.estimate(quantile: 0.001) == 1.5)
        #expect(histogram.estimate(quantile: 0.010) == 10.5)
        #expect(histogram.estimate(quantile: 0.500) == 500.25)
        #expect(histogram.estimate(quantile: 0.990) == 990.25)
        #expect(histogram.estimate(quantile: 0.999) == 999.5)
        #expect(histogram.estimate(quantile: 1.000) == 1000)
    }
    @Test
    static func Signed()
    {
        let histogram:OnlineCDF = .init(resolution: 100,
            seeds: (1 ... 100).flatMap { [.init($0), .init(-$0)] })

        #expect(histogram.weight == 200)
        #expect(histogram.mean == 0)
        #expect(histogram.min == -100)
        #expect(histogram.max == 100)
        #expect(histogram.sum == 0)

        #expect(histogram.estimate(quantile: 0.000) == -100)
        #expect(histogram.estimate(quantile: 0.001) == -100)
        #expect(histogram.estimate(quantile: 0.010) == -98.5)
        #expect(histogram.estimate(quantile: 0.990) ==  98.5)
        #expect(histogram.estimate(quantile: 0.999) ==  100)
        #expect(histogram.estimate(quantile: 1.000) ==  100)
    }
    @Test
    static func Outliers()
    {
        var histogram:OnlineCDF = .init(resolution: 100,
            sorted: (1 ..< 100).map(Double.init(_:)))
        histogram.insert(1_000_000)

        #expect(histogram.estimate(quantile: 0.000) == 1)
        #expect(histogram.estimate(quantile: 0.001) == 1)
        #expect(histogram.estimate(quantile: 0.010) == 1.5)
        #expect(histogram.estimate(quantile: 0.500) == 50.375)
        #expect(histogram.estimate(quantile: 0.900) == 90.5)
        #expect(histogram.estimate(quantile: 1.000) == 1_000_000)
    }
    @Test
    static func StepsBalanced()
    {
        var histogram:OnlineCDF = .init(resolution: 100,
            sorted: [Double].init(repeatElement(1, count: 100)))
        histogram.insert(
            sorted: [Double].init(repeatElement(3, count: 100)))
        histogram.insert(
            sorted: [Double].init(repeatElement(2, count: 100)))

        #expect(histogram.estimate(quantile: 0.0) == 1)
        #expect(histogram.estimate(quantile: 0.1) == 1)
        #expect(histogram.estimate(quantile: 0.2) == 1)
        #expect(histogram.estimate(quantile: 0.3) == 1)
        #expect(histogram.estimate(quantile: 0.4) == 2)
        #expect(histogram.estimate(quantile: 0.5) == 2)
        #expect(histogram.estimate(quantile: 0.6) == 2)
        #expect(histogram.estimate(quantile: 0.7) == 3)
        #expect(histogram.estimate(quantile: 0.8) == 3)
        #expect(histogram.estimate(quantile: 0.9) == 3)
        #expect(histogram.estimate(quantile: 1.0) == 3)
    }
    @Test
    static func StepsUnbalanced()
    {
        var histogram:OnlineCDF = .init(resolution: 100,
            sorted: [Double].init(repeatElement(2, count: 50)))
        histogram.insert(
            sorted: [Double].init(repeatElement(1, count: 100)))
        histogram.insert(
            sorted: [Double].init(repeatElement(3, count: 50)))

        #expect(histogram.estimate(quantile: 0.0) == 1)
        #expect(histogram.estimate(quantile: 0.1) == 1)
        #expect(histogram.estimate(quantile: 0.2) == 1)
        #expect(histogram.estimate(quantile: 0.3) == 1)
        #expect(histogram.estimate(quantile: 0.4) == 1)
        #expect(histogram.estimate(quantile: 0.5) == 1.5)
        #expect(histogram.estimate(quantile: 0.6) == 2)
        #expect(histogram.estimate(quantile: 0.7) == 2)
        #expect(histogram.estimate(quantile: 0.8) == 3)
        #expect(histogram.estimate(quantile: 0.9) == 3)
        #expect(histogram.estimate(quantile: 1.0) == 3)
    }
}
