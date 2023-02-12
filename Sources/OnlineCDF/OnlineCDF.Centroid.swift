extension OnlineCDF
{
    struct Centroid
    {
        var weight:Double
        var mean:Double

        init(weight:Double = 1, mean:Double)
        {
            self.weight = weight
            self.mean = mean
        }
    }
}
extension OnlineCDF.Centroid
{
    var sum:Double
    {
        self.weight * self.mean
    }
    
    mutating
    func add(weight:Double, sum:Double) -> Double
    {
        let sum:Double = self.sum + sum

        self.weight += weight
        self.mean = sum / self.weight

        return sum
    }
}
