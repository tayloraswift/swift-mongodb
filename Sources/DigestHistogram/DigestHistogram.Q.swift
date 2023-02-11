extension DigestHistogram
{
    struct Q
    {
        let value:Double
    }
}
extension DigestHistogram.Q
{
    init(_ k:Int, capacity:Int)
    {
        let base:Double = .init(k) / .init(capacity)
        if  base < 0.5
        {
            self.init(value:     2 * base * base)
        }
        else
        {
            let base:Double = 1 - base
            self.init(value: 1 - 2 * base * base)
        }
    }

    static
    func * (lhs:Self, rhs:Int) -> Double
    {
        lhs.value * .init(rhs)
    }
}
