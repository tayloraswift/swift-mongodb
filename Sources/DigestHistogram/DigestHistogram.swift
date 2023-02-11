//  Based on a C++ implementation from Facebook’s Folly library.
//
//  https://github.com/facebook/folly/blob/main/folly/stats/TDigest.h

public
struct DigestHistogram:Sendable
{
    let capacity:Int

    private
    var centroids:[Centroid]

    public private(set)
    var samples:Int
    public private(set)
    var sum:Double

    public private(set)
    var min:Double
    public private(set)
    var max:Double

    init(capacity:Int, samples:Int,
        min:Double =  .infinity,
        max:Double = -.infinity)
    {
        self.capacity = capacity

        self.centroids = []
        self.centroids.reserveCapacity(capacity)

        self.samples = samples
        self.sum = 0

        self.min = min
        self.max = max
    }
}

extension DigestHistogram
{
    public
    init(capacity:Int = 100)
    {
        self.init(capacity: capacity, samples: 0)
    }
}
extension DigestHistogram
{
    public
    var mean:Double
    {
        self.samples != 0 ? self.sum / .init(self.samples) : 0
    }
}

extension DigestHistogram
{
    public mutating
    func insert(sorted:[Double])
    {
        self = self.merged(with: sorted)
    }
    public mutating
    func insert(_ sample:Double)
    {
        self = self.merged(with: CollectionOfOne<Double>.init(sample))
    }
    @inlinable public mutating
    func insert(_ samples:some RandomAccessCollection<Double>)
    {
        self.insert(sorted: samples.sorted())
    }
}
extension DigestHistogram
{
    private
    func limit(k:Int) -> Double
    {
        let q:Q = .init(k, capacity: self.capacity)
        return q * self.samples
    }

    private
    func merged<Samples>(with sorted:Samples) -> Self
        where Samples:RandomAccessCollection<Double>
    {
        var centroids:IndexingIterator<[Centroid]> = self.centroids.makeIterator()
        var samples:Samples.Iterator = sorted.makeIterator()

        var next:(centroid:Centroid?, sample:Double?) = (centroids.next(), samples.next())
        var previous:Centroid
        var merged:Self

        if  let lowest:Double = next.sample
        {
            merged = .init(capacity: self.capacity,
                samples: self.samples + sorted.count,
                min: Swift.min(self.min, lowest),
                max: Swift.max(self.max, sorted[sorted.index(before: sorted.endIndex)]))
            
            if  let centroid:Centroid = next.centroid,
                    centroid.mean < lowest
            {
                next.centroid = centroids.next()
                previous = centroid
            }
            else
            {
                next.sample = samples.next()
                previous = .init(mean: lowest)
            }
        }
        else
        {
            return self
        }

        var accumulated:Double = previous.weight

        merging:
        for k:Int in 1...
        {
            let limit:Double = merged.limit(k: k)

            var weightsToMerge:Double = 0
            var sumsToMerge:Double = 0

            while true
            {
                let new:Centroid

                switch next
                {
                case (centroid: nil, sample: nil):
                    merged.sum += previous.add(weight: weightsToMerge, sum: sumsToMerge)
                    merged.centroids.append(previous)
                    break merging

                case (centroid: let centroid?, sample: nil):
                    next.centroid = centroids.next()
                    new = centroid
                
                case (centroid: let centroid, sample: let sample?):
                    if  let centroid:Centroid,
                            centroid.mean < sample
                    {
                        next.centroid = centroids.next()
                        new = centroid
                    }
                    else
                    {
                        next.sample = samples.next()
                        new = .init(mean: sample)
                    }
                }

                accumulated += new.weight

                if  limit < accumulated
                {
                    merged.sum += previous.add(weight: weightsToMerge, sum: sumsToMerge)
                    merged.centroids.append(previous)
                    previous = new
                    continue merging
                }
                else
                {
                    sumsToMerge += new.sum
                    weightsToMerge += new.weight
                }
            }
        }
        merged.centroids.sort
        {
            $0.mean < $1.mean
        }
        return merged
    }
}

extension DigestHistogram
{
    private
    func resolve(upper quantile:Double) -> (index:Int, fraction:Double)
    {
        let unit:Double = .init(self.samples)
        let rank:Double = quantile * unit

        var remaining:Double = unit
        for index:Int in self.centroids.indices.reversed()
        {
            remaining -= self.centroids[index].weight

            if rank >= remaining
            {
                return (index, rank - remaining)
            }
        }

        return (self.centroids.startIndex, rank - remaining)
    }
    private
    func resolve(lower quantile:Double) -> (index:Int, fraction:Double)
    {
        let unit:Double = .init(self.samples)
        let rank:Double = quantile * unit

        var accumulated:Double = 0
        for index:Int in self.centroids.indices
        {
            let combined:Double = accumulated + self.centroids[index].weight

            if rank < combined
            {
                return (index, rank - accumulated)
            }
            else
            {
                accumulated = combined
            }
        }

        return (self.centroids.index(before: self.centroids.endIndex), rank - accumulated)
    }
    public
    func estimate(quantile:Double) -> Double
    {
        if self.centroids.isEmpty
        {
            return 0
        }

        let index:Int
        let fraction:Double
        
        if quantile < 0.5
        {
            if quantile > 0
            {
                (index, fraction) = self.resolve(lower: quantile)
            }
            else
            {
                return self.min
            }
        }
        else
        {
            if quantile < 1
            {
                (index, fraction) = self.resolve(upper: quantile)
            }
            else
            {
                return self.max
            }
        }

        let before:Centroid?
        let main:Centroid = self.centroids[index]
        let after:Centroid?

        let range:ClosedRange<Double>
        let delta:Double
        if  self.centroids.count == 1
        {
            before = nil
            after = nil
        }
        else
        {
            before = index == self.centroids.startIndex ?
                nil : self.centroids[self.centroids.index(before: index)]
            
            after = index == self.centroids.index(before: self.centroids.endIndex) ?
                nil : self.centroids[self.centroids.index(after: index)]
        }

        switch (before, after)
        {
        case (nil, nil):
            delta = 0
            range = self.min ... self.max
        
        case (nil, let after?):
            delta = after.mean - main.mean
            range = self.min ... after.mean
        
        case (let before?, let after?):
            delta = 0.5 * (after.mean - before.mean)
            range = before.mean ... after.mean
        
        case (let before?, nil):
            delta = main.mean - before.mean
            range = before.mean ... self.max
        }

        let value:Double = main.mean + (fraction / main.weight - 0.5) * delta
        return Swift.max(range.lowerBound, Swift.min(value, range.upperBound))
    }
}
