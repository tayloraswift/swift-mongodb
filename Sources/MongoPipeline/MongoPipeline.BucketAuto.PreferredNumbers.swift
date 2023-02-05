import BSONDecoding
import BSONEncoding

extension MongoPipeline.BucketAuto
{
    @frozen public
    enum PreferredNumbers:String, Hashable, Sendable
    {
        case e6 = "E6"
        case e12 = "E12"
        case e24 = "E24"
        case e48 = "E48"
        case e96 = "E96"
        case e192 = "E192"

        case i125 = "1-2-5"

        case powersOfTwo = "POWERSOF2"

        case r5 = "R5"
        case r10 = "R10"
        case r20 = "R20"
        case r40 = "R40"
        case r80 = "R80"
    }
}
extension MongoPipeline.BucketAuto.PreferredNumbers:BSONDecodable, BSONEncodable
{
}
