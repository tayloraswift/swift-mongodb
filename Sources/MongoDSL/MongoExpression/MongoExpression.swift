// extension MongoExpression
// {
//     @available(*, unavailable, renamed: "element(of:at:)")
//     public static
//     func arrayElemAt(_ array:Self, _ index:Self) -> Self
//     {
//         .element(of: array, at: index)
//     }
//     @available(*, unavailable, renamed: "toDocument(array:)")
//     public static
//     func arrayToObject(_ array:Self) -> Self
//     {
//         .toDocument(array: array)
//     }
//     @available(*, unavailable, renamed: "toArray(document:)")
//     public static
//     func objectToArray(_ document:Self) -> Self
//     {
//         .toArray(document: document)
//     }
//     @available(*, unavailable, renamed: "concat(arrays:)")
//     public static
//     func concatArrays(_ arrays:[Self]) -> Self
//     {
//         .concat(arrays: arrays)
//     }
//     @available(*, unavailable, renamed: "filter(_:where:limit:as:)")
//     public static
//     func filter(input array:Self, cond predicate:Self, as binding:String?, limit:Self) -> Self
//     {
//         .filter(array, where: predicate, limit: limit, as: binding)
//     }
//     @available(*, unavailable, renamed: "first(_:of:)")
//     public static
//     func firstN(_ count:Self, array:Self) -> Self
//     {
//         .first(count, of: array)
//     }
//     @available(*, unavailable, renamed: "index(of:in:range:)")
//     public static
//     func indexOfArray(_ array:Self, expression:Self, start:Self?, end:Self?) -> Self
//     {
//         .index(of: expression, in: array, range: start.map { ($0, end) })
//     }
//     @available(*, unavailable, renamed: "last(_:of:)")
//     public static
//     func lastN(_ count:Self, array:Self) -> Self
//     {
//         .last(count, of: array)
//     }
//     @available(*, unavailable, renamed: "max(_:of:)")
//     public static
//     func maxN(_ count:Self, array:Self) -> Self
//     {
//         .max(count, of: array)
//     }
//     @available(*, unavailable, renamed: "min(_:of:)")
//     public static
//     func minN(_ count:Self, array:Self) -> Self
//     {
//         .min(count, of: array)
//     }
//     @available(*, unavailable, renamed: "reverse(array:)")
//     public static
//     func reverseArray(_ array:Self) -> Self
//     {
//         .reverse(array: array)
//     }
//     @available(*, unavailable,
//         message: "use one of count(of:), size(binary:), or size(document:).")
//     public static
//     func size(of array:Self) -> Self
//     {
//         .count(of: array)
//     }
//     @available(*, unavailable, renamed: "sort(array:by:)")
//     public static
//     func sortArray(_ array:Self, by ordering:Self) -> Self
//     {
//         .sort(array, by: ordering)
//     }
// }
// extension MongoExpression
// {
//     @inlinable public static
//     func element(of array:Self, at index:Self) -> Self
//     {
//         .document
//         {
//             $0["$arrayElemAt"] = [array, index]
//         }
//     }
    
//     @inlinable public static
//     func toArray(document:Self) -> Self
//     {
//         .document
//         {
//             $0["$objectToArray"] = document
//         }
//     }
    
//     @inlinable public static
//     func toDocument(array:Self) -> Self
//     {
//         .document
//         {
//             $0["$arrayToObject"] = array
//         }
//     }

//     @inlinable public static
//     func concat(arrays:Self...) -> Self
//     {
//         .concat(arrays: arrays)
//     }
//     @inlinable public static
//     func concat(arrays:[Self]) -> Self
//     {
//         .document
//         {
//             $0["$concatArrays"] = arrays
//         }
//     }

//     @inlinable public static
//     func first(of array:Self) -> Self
//     {
//         .document
//         {
//             $0["$first"] = array
//         }
//     }

//     @inlinable public static
//     func first(_ count:Self, of array:Self) -> Self
//     {
//         .document
//         {
//             $0["$firstN"] = .init
//             {
//                 $0["n"] = count
//                 $0["input"] = array
//             }
//         }
//     }
    
//     @inlinable public static
//     func `in`(_ expression:Self, in array:Self) -> Self
//     {
//         .document
//         {
//             $0["$in"] = [expression, array]
//         }
//     }

//     @inlinable public static
//     func index(of expression:Self, in array:Self, range:(start:Self, end:Self?)? = nil) -> Self
//     {
//         .document
//         {
//             $0["$indexOfArray"] = .init
//             {
//                 $0.append(array)
//                 $0.append(expression)

//                 if let range:(start:Self, end:Self?)
//                 {
//                     $0.append(range.start)

//                     if let end:Self = range.end
//                     {
//                         $0.append(end)
//                     }
//                 }
//             }
//         }
//     }

//     /// Creates an `$isArray` expression. This method already brackets the expression
//     /// when passing it in an argument tuple; doing so manually will create an
//     /// expression that always evaluates to true.
//     @inlinable public static
//     func isArray(_ expression:Self) -> Self
//     {
//         .document
//         {
//             $0["$isArray"] = [expression]
//         }
//     }

//     @inlinable public static
//     func last(of array:Self) -> Self
//     {
//         .document
//         {
//             $0["$last"] = array
//         }
//     }

//     @inlinable public static
//     func last(_ count:Self, of array:Self) -> Self
//     {
//         .document
//         {
//             $0["$lastN"] = .init
//             {
//                 $0["n"] = count
//                 $0["input"] = array
//             }
//         }
//     }

//     @inlinable public static
//     func max(_ count:Self, of array:Self) -> Self
//     {
//         .document
//         {
//             $0["$maxN"] = .init
//             {
//                 $0["n"] = count
//                 $0["input"] = array
//             }
//         }
//     }

//     @inlinable public static
//     func min(_ count:Self, of array:Self) -> Self
//     {
//         .document
//         {
//             $0["$minN"] = .init
//             {
//                 $0["n"] = count
//                 $0["input"] = array
//             }
//         }
//     }

//     public static
//     func range(from start:Self, to end:Self, by step:Self? = nil) -> Self
//     {
//         .document
//         {
//             if let step:Self
//             {
//                 $0["$range"] = [start, end, step]
//             }
//             else
//             {
//                 $0["$range"] = [start, end]
//             }
//         }
//     }

//     @inlinable public static
//     func reverse(array:Self) -> Self
//     {
//         .document
//         {
//             $0["$reverseArray"] = array
//         }
//     }

//     /// Creates a `$size` expression. This method is named `count` to avoid
//     /// confusion with ``size(binary:)`` and ``size(document:)``, which evaluate
//     /// to sizes in units of bytes.
//     @inlinable public static
//     func count(of array:Self) -> Self
//     {
//         .document
//         {
//             $0["$size"] = array
//         }
//     }
    
//     @inlinable public static
//     func slice(_ array:Self, distance:Self) -> Self
//     {
//         .document
//         {
//             $0["$slice"] = [array, distance]
//         }
//     }
//     @inlinable public static
//     func slice(_ array:Self, at index:Self, count:Self) -> Self
//     {
//         .document
//         {
//             $0["$slice"] = [array, index, count]
//         }
//     }

//     @inlinable public static
//     func sort(_ array:Self, by populate:(inout Document) throws -> ()) rethrows -> Self
//     {
//         .sort(array, by: try .document(populate))
//     }
//     @inlinable public static
//     func sort(_ array:Self, by ordering:Self) -> Self
//     {
//         .document
//         {
//             $0["$sortArray"] = .init
//             {
//                 $0["input"] = array
//                 $0["sortBy"] = ordering
//             }
//         }
//     }

//     @inlinable public static
//     func zip(arrays:Self...) -> Self
//     {
//         .zip(arrays: arrays)
//     }
//     @inlinable public static
//     func zip(arrays:[Self]) -> Self
//     {
//         .document
//         {
//             $0["$zip"] = .init
//             {
//                 $0["inputs"] = arrays
//             }
//         }
//     }

//     @inlinable public static
//     func zip(padding arrays:Self..., with values:Self) -> Self
//     {
//         .zip(padding: arrays, with: values)
//     }
//     @inlinable public static
//     func zip(padding arrays:[Self], with values:Self) -> Self
//     {
//         .document
//         {
//             $0["$zip"] = .init
//             {
//                 $0["inputs"] = arrays
//                 $0["useLongestLength"] = true
//                 $0["defaults"] = values
//             }
//         }
//     }
// }
// extension MongoExpression
// {
//     @inlinable public static
//     func filter(_ array:Self, where predicate:Self, limit:Self, as binding:String?) -> Self
//     {
//         .document
//         {
//             $0["$filter"] = .init
//             {
//                 $0["input"] = array
//                 $0["limit"] = limit
//                 $0["cond"] = predicate
//                 $0["as"] = binding
//             }
//         }
//     }

//     @inlinable public static
//     func map(_ array:Self, as binding:String?, in transform:Self) -> Self
//     {
//         .document
//         {
//             $0["$map"] = .init
//             {
//                 $0["input"] = array
//                 $0["as"] = binding
//                 $0["in"] = transform
//             }
//         }
//     }

//     @inlinable public static
//     func reduce(_ array:Self, from initialValue:Self, combine:Self) -> Self
//     {
//         .document
//         {
//             $0["$reduce"] = .init
//             {
//                 $0["input"] = array
//                 $0["initialValue"] = initialValue
//                 $0["in"] = combine
//             }
//         }
//     }
// }

// extension MongoExpression
// {
//     @inlinable public static
//     func and(_ expressions:Self...) -> Self
//     {
//         .and(expressions)
//     }
//     @inlinable public static
//     func and(_ expressions:[Self]) -> Self
//     {
//         .document
//         {
//             $0["$and"] = expressions
//         }
//     }

//     /// Creates a `$not` expression. This method already brackets the expression
//     /// when passing it in an argument tuple; doing so manually will create an
//     /// expression that always evaluates to false. (Because an empty array
//     /// evaluates to true.)
//     @inlinable public static
//     func not(_ expression:Self) -> Self
//     {
//         .document
//         {
//             $0["$not"] = [expression]
//         }
//     }

//     @inlinable public static
//     func or(_ expressions:Self...) -> Self
//     {
//         .or(expressions)
//     }
//     @inlinable public static
//     func or(_ expressions:[Self]) -> Self
//     {
//         .document
//         {
//             $0["$or"] = expressions
//         }
//     }
// }
// //  We consider `$cmp`, `$gt`, etc. to be terms of art.
// //  So unlike things like `$lastN`, we do not rename them to
// //  `compare`, `greaterThan`, etc.
// extension MongoExpression
// {
//     @inlinable public static
//     func cmp(_ lhs:Self, _ rhs:Self) -> Self
//     {
//         .document
//         {
//             $0["$cmp"] = [lhs, rhs]
//         }
//     }
//     @inlinable public static
//     func eq(_ lhs:Self, _ rhs:Self) -> Self
//     {
//         .document
//         {
//             $0["$eq"] = [lhs, rhs]
//         }
//     }
//     @inlinable public static
//     func gt(_ lhs:Self, _ rhs:Self) -> Self
//     {
//         .document
//         {
//             $0["$gt"] = [lhs, rhs]
//         }
//     }
//     @inlinable public static
//     func gte(_ lhs:Self, _ rhs:Self) -> Self
//     {
//         .document
//         {
//             $0["$gte"] = [lhs, rhs]
//         }
//     }
//     @inlinable public static
//     func lt(_ lhs:Self, _ rhs:Self) -> Self
//     {
//         .document
//         {
//             $0["$lt"] = [lhs, rhs]
//         }
//     }
//     @inlinable public static
//     func lte(_ lhs:Self, _ rhs:Self) -> Self
//     {
//         .document
//         {
//             $0["$lte"] = [lhs, rhs]
//         }
//     }
//     @inlinable public static
//     func ne(_ lhs:Self, _ rhs:Self) -> Self
//     {
//         .document
//         {
//             $0["$ne"] = [lhs, rhs]
//         }
//     }
// }

// extension MongoExpression
// {
//     @available(*, unavailable, renamed: "coalesce(_:)")
//     public static
//     func ifNull(_ expressions:[Self]) -> Self
//     {
//         .coalesce(expressions)
//     }
// }
// extension MongoExpression
// {
//     @inlinable public static
//     func cond(if condition:Self, then first:Self, else second:Self) -> Self
//     {
//         .document
//         {
//             $0["$cond"] = [condition, first, second]
//         }
//     }

//     @inlinable public static
//     func coalesce(_ expressions:Self...) -> Self
//     {
//         .coalesce(expressions)
//     }
//     @inlinable public static
//     func coalesce(_ expressions:[Self]) -> Self
//     {
//         .document
//         {
//             $0["$ifNull"] = .init(elements: expressions)
//         }
//     }

//     @inlinable public static
//     func `switch`(cases:(pattern:Self, block:Self)..., `default`:Self? = nil) -> Self
//     {
//         .switch(cases: cases, default: `default`)
//     }
//     @inlinable public static
//     func `switch`(cases:[(pattern:Self, block:Self)], `default`:Self? = nil) -> Self
//     {
//         .document
//         {
//             $0["$switch"] = .init
//             {
//                 $0["branches"] = .init
//                 {
//                     for (pattern, block):(Self, Self) in cases
//                     {
//                         $0.append
//                         {
//                             $0["case"] = pattern
//                             $0["then"] = block
//                         }
//                     }
//                 }
//                 $0["default"] = `default`
//             }
//         }
//     }
// }

// extension MongoExpression
// {
//     @available(*, unavailable, renamed: "size(binary:)")
//     public static
//     func binarySize(_ binary:Self) -> Self
//     {
//         .size(binary: binary)
//     }
//     @available(*, unavailable, renamed: "size(document:)")
//     public static
//     func bsonSize(_ document:Self) -> Self
//     {
//         .size(document: document)
//     }
// }
// extension MongoExpression
// {
//     /// Creates a `$binarySize` expression. The operand can be an expression
//     /// that resolves to either binary data or a BSON UTF-8 string.
//     @inlinable public static
//     func size(binary:Self) -> Self
//     {
//         .document
//         {
//             $0["$binarySize"] = binary
//         }
//     }
//     @inlinable public static
//     func size(document:Self) -> Self
//     {
//         .document
//         {
//             $0["$bsonSize"] = document
//         }
//     }
// }
