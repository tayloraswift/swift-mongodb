// import BSONEncoding

// @frozen public
// struct MongoAccumulator
// {
//     public
//     let encoded:BSON.Fields

//     @inlinable public
//     init(encoded:BSON.Fields)
//     {
//         self.encoded = encoded
//     }
// }
// extension MongoAccumulator
// {
//     @inlinable public
//     init(_ name:String, value:some BSONEncodable)
//     {
//         self.init(encoded: .init
//         {
//             $0[name] = value
//         })
//     }
//     @inlinable public
//     init<DSL>(_ name:String,
//         with populate:(inout DSL) throws -> ()) rethrows where DSL:BSONDSL & BSONEncodable
//     {
//         self.init(name, value: try DSL.init(with: populate))
//     }
// }
// extension MongoAccumulator:BSONEncodable
// {
//     public
//     func encode(to field:inout BSON.Field)
//     {
//         self.encoded.encode(to: &field)
//     }
// }
// extension MongoAccumulator
// {
//     @inlinable public static
//     func addToSet(_ expression:MongoExpression) -> Self
//     {
//         .init("$addToSet", value: expression)
//     }

//     @inlinable public static
//     func avg(_ expression:MongoExpression) -> Self
//     {
//         .init("$avg", value: expression)
//     }

//     @inlinable public static
//     func bottom(of expression:MongoExpression,
//         by populate:(inout BSON.Fields) throws -> ()) rethrows -> Self
//     {
//         .bottom(of: expression, by: try .init(with: populate))
//     }
//     @inlinable public static
//     func bottom(of expression:MongoExpression, by ordering:BSON.Fields) -> Self
//     {
//         .init("$bottom")
//         {
//             (bson:inout BSON.Fields) in

//             bson["output"] = expression
//             bson["sortBy"] = ordering
//         }
//     }

//     @inlinable public static
//     func bottom(_ count:MongoExpression, of expression:MongoExpression,
//         by populate:(inout BSON.Fields) throws -> ()) rethrows -> Self
//     {
//         .bottom(count, of: expression, by: try .init(with: populate))
//     }
//     @inlinable public static
//     func bottom(_ count:MongoExpression, of expression:MongoExpression,
//         by ordering:BSON.Fields) -> Self
//     {
//         .init("$bottomN")
//         {
//             (bson:inout BSON.Fields) in

//             bson["output"] = expression
//             bson["sortBy"] = ordering
//             bson["n"] = count
//         }
//     }
// }
// extension MongoAccumulator
// {
//     func example()
//     {
//         [
//             .group
//             {
//                 $0[.id] = "$field"
//                 $0[.id] = .init
//                 {
//                     $0[.concat] = .tuple
//                     {
//                         "$flag"
//                         ".value"
//                     }
//                 }
//             },
//         ]
//     }
//     public
//     enum BottomN
//     {

//     }
// }
