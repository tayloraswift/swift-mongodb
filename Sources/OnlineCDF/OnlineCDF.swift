//  Based on a C++ implementation from Facebook’s Folly library.
//
//  https://github.com/facebook/folly/blob/main/folly/stats/TDigest.h

public
struct OnlineCDF:Sendable
{
    public
    let resolution:Int

    private
    var centroids:[Centroid]

    public private(set)
    var weight:Double
    public private(set)
    var min:Double
    public private(set)
    var max:Double
    public private(set)
    var sum:Double

    private
    init(resolution:Int, centroids:[Centroid],
        weight:Double,
        min:Double,
        max:Double,
        sum:Double)
    {
        self.resolution = resolution

        self.centroids = centroids
        self.centroids.reserveCapacity(resolution)

        self.weight = weight
        self.min = min
        self.max = max
        self.sum = sum
    }
}

extension OnlineCDF
{
    private
    init(resolution:Int,
        weight:Double,
        min:Double,
        max:Double)
    {
        self.init(resolution: resolution, centroids: [],
            weight: weight,
            min: min,
            max: max,
            sum: 0)
    }
}
extension OnlineCDF
{
    public
    init(resolution:Int, seed:Double)
    {
        let seed:Centroid = .init(weight: 1, mean: seed)
        self.init(resolution: resolution, centroids: [seed],
            weight: seed.weight,
            min: seed.mean,
            max: seed.mean,
            sum: seed.sum)
    }
    public
    init(resolution:Int, sorted:[Double])
    {
        if sorted.isEmpty
        {
            fatalError("CDF seed values list cannot be empty.")
        }

        self.init(resolution: resolution, weight: 0,
            min:  .infinity,
            max: -.infinity)
        self.insert(sorted: sorted)
    }
    @inlinable public
    init(resolution:Int, seeds:some Sequence<Double>)
    {
        self.init(resolution: resolution, sorted: seeds.sorted())
    }
}
extension OnlineCDF
{
    public
    var mean:Double
    {
        self.weight != 0 ? self.sum / self.weight : 0
    }
}

extension OnlineCDF
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
    func insert(_ samples:some Sequence<Double>)
    {
        self.insert(sorted: samples.sorted())
    }
}
extension OnlineCDF
{
    private
    func limit(k:Int) -> Double
    {
        let base:Double = .init(k) / .init(self.resolution)
        if  base < 0.5
        {
            return self.weight * (    2 * base * base)
        }
        else
        {
            let base:Double = 1 - base
            return self.weight * (1 - 2 * base * base)
        }
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
            merged = .init(resolution: self.resolution,
                weight: self.weight + .init(sorted.count),
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
            var unmerged:(weight:Double, sum:Double) = (0, 0)

            let limit:Double = merged.limit(k: k)
            while true
            {
                let new:Centroid

                switch next
                {
                case (centroid: nil, sample: nil):
                    merged.sum += previous.add(weight: unmerged.weight, sum: unmerged.sum)
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
                    merged.sum += previous.add(weight: unmerged.weight, sum: unmerged.sum)
                    merged.centroids.append(previous)
                    previous = new
                    continue merging
                }
                else
                {
                    unmerged.weight += new.weight
                    unmerged.sum += new.sum
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

extension OnlineCDF
{
    public
    func estimate(quantile:Double) -> Double
    {
        assert(!self.centroids.isEmpty)

        let index:Int
        let fraction:Double
        
        if quantile < 0.5
        {
            if quantile > 0
            {
                (index, fraction) = self.snap(lower: quantile)
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
                (index, fraction) = self.snap(upper: quantile)
            }
            else
            {
                return self.max
            }
        }

        let main:Centroid = self.centroids[index]

        let before:Centroid? = index == self.centroids.startIndex ?
            nil : self.centroids[self.centroids.index(before: index)]
        let after:Centroid? = index == self.centroids.index(before: self.centroids.endIndex) ?
            nil : self.centroids[self.centroids.index(after: index)]

        let range:ClosedRange<Double>
        let delta:Double

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

    private
    func snap(upper quantile:Double) -> (index:Int, fraction:Double)
    {
        let rank:Double = self.weight * quantile

        var remaining:Double = self.weight
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
    func snap(lower quantile:Double) -> (index:Int, fraction:Double)
    {
        let rank:Double = self.weight * quantile

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
}
