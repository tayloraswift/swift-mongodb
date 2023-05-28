import Base16
import BSON
import BSONReflection
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/multi-type.json
        // cannot use this test, because it encodes a deprecated binary subtype, which is
        // (intentionally) impossible to construct with swift-bson.

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/maxkey.json
        do
        {
            TestValidBSON(tests / "max",
                canonical: "080000007F610000",
                expected: ["a": .max])
        }
        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/minkey.json
        do
        {
            TestValidBSON(tests / "min",
                canonical: "08000000FF610000",
                expected: ["a": .min])
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/null.json
        do
        {
            TestValidBSON(tests / "null",
                canonical: "080000000A610000",
                expected: ["a": .null])
        }
        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/undefined.json
        do
        {
            TestValidBSON(tests / "undefined",
                degenerate: "0800000006610000",
                canonical: "080000000A610000",
                expected: ["a": .null])
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/boolean.json
        if  let tests:TestGroup = tests / "bool"
        {

            TestValidBSON(tests / "true",
                canonical: "090000000862000100",
                expected: ["b": true])
            TestValidBSON(tests / "false",
                canonical: "090000000862000000",
                expected: ["b": false])

            TestInvalidBSON(tests / "invalid-subtype",
                invalid: "090000000862000200",
                catching: BSON.BooleanSubtypeError.init(invalid: 2))

            TestInvalidBSON(tests / "invalid-subtype-negative",
                invalid: "09000000086200FF00",
                catching: BSON.BooleanSubtypeError.init(invalid: 255))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/int32.json
        if  let tests:TestGroup = tests / "int32"
        {

            TestValidBSON(tests / "min",
                canonical: "0C0000001069000000008000",
                expected: ["i": .int32(-2147483648)])

            TestValidBSON(tests / "max",
                canonical: "0C000000106900FFFFFF7F00",
                expected: ["i": .int32(2147483647)])

            TestValidBSON(tests / "-1",
                canonical: "0C000000106900FFFFFFFF00",
                expected: ["i": .int32(-1)])

            TestValidBSON(tests / "0",
                canonical: "0C0000001069000000000000",
                expected: ["i": .int32(0)])

            TestValidBSON(tests / "+1",
                canonical: "0C0000001069000100000000",
                expected: ["i": .int32(1)])

            TestInvalidBSON(tests / "truncated",
                invalid: "09000000_10_6100_05_00",
                catching: BSON.InputError.init(expected: .bytes(4), encountered: 1))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/int32.json
        if  let tests:TestGroup = tests / "int64"
        {

            TestValidBSON(tests / "min",
                canonical: "10000000126100000000000000008000",
                expected: ["a": .int64(-9223372036854775808)])

            TestValidBSON(tests / "max",
                canonical: "10000000126100FFFFFFFFFFFFFF7F00",
                expected: ["a": .int64(9223372036854775807)])

            TestValidBSON(tests / "-1",
                canonical: "10000000126100FFFFFFFFFFFFFFFF00",
                expected: ["a": .int64(-1)])

            TestValidBSON(tests / "0",
                canonical: "10000000126100000000000000000000",
                expected: ["a": .int64(0)])

            TestValidBSON(tests / "+1",
                canonical: "10000000126100010000000000000000",
                expected: ["a": .int64(1)])

            TestInvalidBSON(tests / "truncated",
                invalid: "0C000000_12_6100_12345678_00",
                catching: BSON.InputError.init(expected: .bytes(8), encountered: 4))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/timestamp.json
        if  let tests:TestGroup = tests / "uint64"
        {

            TestValidBSON(tests / "(123456789, 42)",
                canonical: "100000001161002A00000015CD5B0700",
                expected: ["a": .uint64(123456789 << 32 | 42)])

            TestValidBSON(tests / "ones",
                canonical: "10000000116100FFFFFFFFFFFFFFFF00",
                expected: ["a": .uint64(.max)])

            TestValidBSON(tests / "(4000000000, 4000000000)",
                canonical: "1000000011610000286BEE00286BEE00",
                expected: ["a": .uint64(4000000000 << 32 | 4000000000)])

            TestInvalidBSON(tests / "truncated",
                invalid: "0F000000_11_6100_2A00000015CD5B_00",
                catching: BSON.InputError.init(expected: .bytes(8), encountered: 7))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/top.json
        if  let tests:TestGroup = tests / "top"
        {

            TestValidBSON(tests / "dollar-prefixed-key",
                canonical: "0F00000010246B6579002A00000000",
                expected: ["$key": .int32(42)])

            TestValidBSON(tests / "dollar-key",
                canonical: "0E00000002240002000000610000",
                expected: ["$": "a"])

            TestValidBSON(tests / "dotted-key",
                canonical: "1000000002612E620002000000630000",
                expected: ["a.b": "c"])

            TestValidBSON(tests / "dot-key",
                canonical: "0E000000022E0002000000610000",
                expected: [".": "a"])

            TestValidBSON(tests / "empty-truncated-header",
                degenerate: "0100000000",
                canonical: "0500000000",
                expected: [:])

            TestValidBSON(tests / "empty",
                canonical: "0500000000",
                expected: [:])

            TestValidBSON(tests / "invalid-end-of-object-0x01",
                degenerate: "05000000_01",
                canonical: "05000000_00",
                expected: [:])

            TestValidBSON(tests / "invalid-end-of-object-0xff",
                degenerate: "05000000_FF",
                canonical: "05000000_00",
                expected: [:])

            TestValidBSON(tests / "invalid-end-of-object-0x70",
                degenerate: "05000000_70",
                canonical: "05000000_00",
                expected: [:])

            TestInvalidBSON(tests / "zeroes",
                invalid: "00000000_000000000000",
                //        ^~~~~~~~
                catching: BSON.HeaderError<BSON.DocumentFrame>.init(length: 0))

            TestInvalidBSON(tests / "invalid-length-over",
                invalid: "12000000_02_666F6F00_04000000_626172",
                //        ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0x12 - 4), encountered: 12))

            TestInvalidBSON(tests / "invalid-length-under",
                invalid: "12000000_02_666F6F00_04000000_62617200_00_DEADBEEF",
                //        ^~~~~~~~
                catching: BSON.InputError.init(expected: .end, encountered: 4))

            TestInvalidBSON(tests / "invalid-type-0x00",
                invalid: "07000000_00_0000",
                //                 ^~
                catching: BSON.TypeError.init(invalid: 0x00))

            TestInvalidBSON(tests / "invalid-type-0x80",
                invalid: "07000000_80_0000",
                //                 ^~
                catching: BSON.TypeError.init(invalid: 0x80))

            TestInvalidBSON(tests / "truncated",
                invalid: "12000000_02_666F",
                catching: BSON.InputError.init(expected: .bytes(0x12 - 4), encountered: 3))

            TestInvalidBSON(tests / "invalid-key",
                invalid: "0D000000_10_7800_00_0100000000",
                //                         ^~
                catching: BSON.TypeError.init(invalid: 0x00))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/decimal128-1.json
        if  let tests:TestGroup = tests / "decimal128"
        {

            TestValidBSON(tests / "positive-quiet-nan",
                canonical: "180000001364000000000000000000000000000000007C00",
                expected: ["d": .decimal128(.init(
                    high: 0x7C00_0000_0000_0000,
                    low:  0x0000_0000_0000_0000))])

            TestValidBSON(tests / "negative-quiet-nan",
                canonical: "18000000136400000000000000000000000000000000FC00",
                expected: ["d": .decimal128(.init(
                    high: 0xFC00_0000_0000_0000,
                    low:  0x0000_0000_0000_0000))])

            TestValidBSON(tests / "positive-signaling-nan",
                canonical: "180000001364000000000000000000000000000000007E00",
                expected: ["d": .decimal128(.init(
                    high: 0x7E00_0000_0000_0000,
                    low:  0x0000_0000_0000_0000))])

            TestValidBSON(tests / "negative-signaling-nan",
                canonical: "18000000136400000000000000000000000000000000FE00",
                expected: ["d": .decimal128(.init(
                    high: 0xFE00_0000_0000_0000,
                    low:  0x0000_0000_0000_0000))])

            // this only serves to verify we are handling byte-order correctly;
            // there is very little point in elaborating decimal128 tests further
            TestValidBSON(tests / "largest",
                canonical: "18000000136400F2AF967ED05C82DE3297FF6FDE3C403000",
                expected: ["d": .decimal128(.init(
                    high: 0x3040_3CDE_6FFF_9732,
                    low:  0xDE82_5CD0_7E96_AFF2))])
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/datetime.json
        if  let tests:TestGroup = tests / "millisecond"
        {

            TestValidBSON(tests / "epoch",
                canonical: "10000000096100000000000000000000",
                expected: ["a": .millisecond(0)])

            TestValidBSON(tests / "positive",
                canonical: "10000000096100C5D8D6CC3B01000000",
                expected: ["a": .millisecond(1356351330501)])

            TestValidBSON(tests / "negative",
                canonical: "10000000096100C33CE7B9BDFFFFFF00",
                expected: ["a": .millisecond(-284643869501)])

            TestValidBSON(tests / "positive-2",
                canonical: "1000000009610000DC1FD277E6000000",
                expected: ["a": .millisecond(253402300800000)])

            TestValidBSON(tests / "positive-3",
                canonical: "10000000096100D1D6D6CC3B01000000",
                expected: ["a": .millisecond(1356351330001)])

            TestInvalidBSON(tests / "truncated",
                invalid: "0C000000_0961001234567800",
                catching: BSON.InputError.init(expected: .bytes(8), encountered: 4))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/double.json
        if  let tests:TestGroup = tests / "double"
        {

            TestValidBSON(tests / "+1.0",
                canonical: "10000000016400000000000000F03F00",
                expected: ["d": .double(1.0)])

            TestValidBSON(tests / "-1.0",
                canonical: "10000000016400000000000000F0BF00",
                expected: ["d": .double(-1.0)])

            TestValidBSON(tests / "+1.0001220703125",
                canonical: "10000000016400000000008000F03F00",
                expected: ["d": .double(1.0001220703125)])

            TestValidBSON(tests / "-1.0001220703125",
                canonical: "10000000016400000000008000F0BF00",
                expected: ["d": .double(-1.0001220703125)])

            TestValidBSON(tests / "1.2345678921232E+18",
                canonical: "100000000164002a1bf5f41022b14300",
                expected: ["d": .double(1.2345678921232e18)])

            TestValidBSON(tests / "-1.2345678921232E+18",
                canonical: "100000000164002a1bf5f41022b1c300",
                expected: ["d": .double(-1.2345678921232e18)])

            // remaining corpus test cases are pointless because swift cannot distinguish
            // between -0.0 and +0.0

            // note: frameshift
            TestInvalidBSON(tests / "truncated",
                invalid: "0B000000_0164000000F03F00",
                //        ^~~~~~~~
                catching: BSON.InputError.init(expected: .end, encountered: 1))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/oid.json
        if  let tests:TestGroup = tests / "id"
        {

            let id:BSON.Identifier = 0x0123_4567_89AB_CDEF_4567_3210

            tests.expect(id.timestamp ==? 0x0123_4567)
            tests.expect(true: id.seed == (0x89, 0xAB, 0xCD, 0xEF, 0x45))
            tests.expect(true: id.ordinal == (0x67, 0x32, 0x10))

            tests.expect(id ==? .init(timestamp: id.timestamp, seed: id.seed, ordinal: id.ordinal))

            TestValidBSON(tests / "zeroes",
                canonical: "1400000007610000000000000000000000000000",
                expected: ["a": .id(0x00000000_00000000_00_000000)])

            TestValidBSON(tests / "ones",
                canonical: "14000000076100FFFFFFFFFFFFFFFFFFFFFFFF00",
                expected: ["a": .id(0xffffffff_ffffffff_ff_ffffff)])

            TestValidBSON(tests / "random",
                canonical: "1400000007610056E1FC72E0C917E9C471416100",
                expected: ["a": .id(0x56e1fc72_e0c917e9_c4_714161)])

            TestInvalidBSON(tests / "truncated",
                invalid: "12000000_07_6100_56E1FC72E0C917E9C471",
                //        ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0x12 - 4), encountered: 13))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/dbpointer.json
        if  let tests:TestGroup = tests / "pointer"
        {

            TestValidBSON(tests / "ascii",
                canonical: "1A0000000C610002000000620056E1FC72E0C917E9C471416100",
                expected: ["a": .pointer(.init(from: "b"), .init(
                    0x56e1fc72, 0xe0c917e9, 0xc4_714161))])

            TestValidBSON(tests / "unicode",
                canonical: "1B0000000C610003000000C3A90056E1FC72E0C917E9C471416100",
                expected: ["a": .pointer(.init(from: "é"), .init(
                    0x56e1fc72, 0xe0c917e9, 0xc4_714161))])

            TestInvalidBSON(tests / "invalid-length-negative",
                invalid: "1A000000_0C_6100_FFFFFFFF_620056E1FC72E0C917E9C471416100",
                //                         ^~~~~~~~
                catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: -1))

            TestInvalidBSON(tests / "invalid-length-zero",
                invalid: "1A000000_0C_6100_00000000_620056E1FC72E0C917E9C471416100",
                //                         ^~~~~~~~
                catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: 0))

            TestInvalidBSON(tests / "truncated",
                invalid: "16000000_0C_6100_03000000_616200_56E1FC72E0C91700",
                catching: BSON.InputError.init(expected: .bytes(12), encountered: 7))

            TestInvalidBSON(tests / "truncated-identifier",
                invalid: "1A000000_0C_6100_03000000_616200_56E1FC72E0C917E9C4716100",
                catching: BSON.InputError.init(expected: .bytes(12), encountered: 11))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/binary.json
        if  let tests:TestGroup = tests / "binary"
        {

            TestValidBSON(tests / "generic-empty",
                canonical: "0D000000057800000000000000",
                expected: ["x": .binary(.init(subtype: .generic, slice: []))])

            TestValidBSON(tests / "generic",
                canonical: "0F0000000578000200000000FFFF00",
                expected: ["x": .binary(.init(subtype: .generic,
                    slice: Base16.decode("ffff")))])

            TestValidBSON(tests / "function",
                canonical: "0F0000000578000200000001FFFF00",
                expected: ["x": .binary(.init(subtype: .function,
                    slice: Base16.decode("ffff")))])

            TestValidBSON(tests / "uuid",
                canonical: "1D000000057800100000000473FFD26444B34C6990E8E7D1DFC035D400",
                expected: ["x": .binary(.init(subtype: .uuid,
                    slice: Base16.decode("73ffd26444b34c6990e8e7d1dfc035d4")))])

            TestValidBSON(tests / "md5",
                canonical: "1D000000057800100000000573FFD26444B34C6990E8E7D1DFC035D400",
                expected: ["x": .binary(.init(subtype: .md5,
                    slice: Base16.decode("73ffd26444b34c6990e8e7d1dfc035d4")))])

            TestValidBSON(tests / "compressed",
                canonical: "1D000000057800100000000773FFD26444B34C6990E8E7D1DFC035D400",
                expected: ["x": .binary(.init(subtype: .compressed,
                    slice: Base16.decode("73ffd26444b34c6990e8e7d1dfc035d4")))])

            TestValidBSON(tests / "custom",
                canonical: "0F0000000578000200000080FFFF00",
                expected: ["x": .binary(.init(subtype: .custom(code: 0x80),
                    slice: Base16.decode("ffff")))])

            TestInvalidBSON(tests / "invalid-length-over",
                invalid: "1D000000_05_7800_FF000000_05_73FFD26444B34C6990E8E7D1DFC035D400",
                //                         ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0xFF + 1), encountered: 17))

            TestInvalidBSON(tests / "invalid-length-negative",
                invalid: "0D000000057800FFFFFFFF0000",
                catching: BSON.BinaryViewError.init(expected: .subtype))
            // TODO: tests for legacy binary subtype 0x02
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/document.json
        if  let tests:TestGroup = tests / "document"
        {

            TestValidBSON(tests / "empty",
                canonical: "0D000000037800050000000000",
                expected: ["x": [:]])

            TestValidBSON(tests / "empty-key",
                canonical: "150000000378000D00000002000200000062000000",
                expected: ["x": ["": "b"]])

            TestValidBSON(tests / "single-character-key",
                canonical: "160000000378000E0000000261000200000062000000",
                expected: ["x": ["a": "b"]])

            TestValidBSON(tests / "dollar-prefixed-key",
                canonical: "170000000378000F000000022461000200000062000000",
                expected: ["x": ["$a": "b"]])

            TestValidBSON(tests / "dollar-key",
                canonical: "160000000378000E0000000224000200000061000000",
                expected: ["x": ["$": "a"]])

            TestValidBSON(tests / "dotted-key",
                canonical: "180000000378001000000002612E62000200000063000000",
                expected: ["x": ["a.b": "c"]])

            TestValidBSON(tests / "dot-key",
                canonical: "160000000378000E000000022E000200000061000000",
                expected: ["x": [".": "a"]])

            TestInvalidBSON(tests / "invalid-length-over",
                invalid: "18000000_03_666F6F00_0F000000_10_62617200_FFFFFF7F_0000",
                //                             ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0x0F - 4), encountered: 10))

            TestInvalidBSON(tests / "invalid-length-under",
                invalid: "15000000_03_666F6F00_0A000000_08_62617200_01_00_00",
                //                                                           ^~
                catching: BSON.InputError.init(expected: .bytes(1)))

            TestInvalidBSON(tests / "invalid-value",
                invalid: "1C000000_03_666F6F00_12000000_02_62617200_05000000_62617A000000",
                //                                                  ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(5), encountered: 4))

            TestInvalidBSON(tests / "invalid-key",
                invalid: "15000000_03_7800_0D000000_10_6100_00010000_00_0000",
                //                                                   ^~
                catching: BSON.TypeError.init(invalid: 0))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/array.json
        if  let tests:TestGroup = tests / "tuple"
        {

            TestValidBSON(tests / "empty",
                canonical: "0D000000046100050000000000",
                expected: ["a": []])
            TestValidBSON(tests / "single-element",
                canonical: "140000000461000C0000001030000A0000000000",
                expected: ["a": [.int32(10)]])

            TestValidBSON(tests / "single-element-empty-key",
                degenerate: "130000000461000B00000010000A0000000000",
                canonical: "140000000461000C0000001030000A0000000000",
                expected: ["a": [.int32(10)]])

            TestValidBSON(tests / "single-element-invalid-key",
                degenerate: "150000000461000D000000106162000A0000000000",
                canonical: "140000000461000C0000001030000A0000000000",
                expected: ["a": [.int32(10)]])

            TestValidBSON(tests / "multiple-element-duplicate-keys",
                degenerate: "1b000000046100130000001030000a000000103000140000000000",
                canonical: "1b000000046100130000001030000a000000103100140000000000",
                expected: ["a": [.int32(10), .int32(20)]])

            TestInvalidBSON(tests / "invalid-length-over",
                invalid: "14000000_04_6100_0D000000_10_30000A00_00_000000",
                //                         ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0x0D - 4), encountered: 8))

            TestInvalidBSON(tests / "invalid-length-under",
                invalid: "14000000_04_6100_0B000000_10_30000A00_00_000000",
                //                         ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(4), encountered: 3))

            TestInvalidBSON(tests / "invalid-element",
                invalid: "1A000000_04_666F6F00_100000000230000500000062617A000000",
                //
                catching: BSON.InputError.init(expected: .bytes(5), encountered: 4))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/regex.json
        if  let tests:TestGroup = tests / "regex"
        {

            TestValidBSON(tests / "empty",
                canonical: "0A0000000B6100000000",
                expected: ["a": .regex(.init(pattern: "", options: []))])

            TestValidBSON(tests / "empty-options",
                canonical: "0D0000000B6100616263000000",
                expected: ["a": .regex(.init(pattern: "abc", options: []))])

            TestValidBSON(tests / "I-HAVE-OPTIONS",
                canonical: "0F0000000B610061626300696D0000",
                expected: ["a": .regex(.init(pattern: "abc", options: [.i, .m]))])

            TestValidBSON(tests / "slash",
                canonical: "110000000B610061622F636400696D0000",
                expected: ["a": .regex(.init(pattern: "ab/cd", options: [.i, .m]))])

            TestValidBSON(tests / "non-alphabetized",
                degenerate: "100000000B6100616263006D69780000",
                canonical: "100000000B610061626300696D780000",
                expected: ["a": .regex(.init(pattern: "abc", options: [.i, .m, .x]))])

            TestValidBSON(tests / "escaped",
                canonical: "100000000B610061625C226162000000",
                expected: ["a": .regex(.init(pattern: #"ab\"ab"#, options: []))])

            // note: frameshift
            TestInvalidBSON(tests / "invalid-pattern",
                invalid: "0F0000000B610061006300696D0000",
                catching: BSON.Regex.OptionError.init(invalid: "c"))
            // note: frameshift
            TestInvalidBSON(tests / "invalid-options",
                invalid: "100000000B61006162630069006D0000",
                catching: BSON.TypeError.init(invalid: 109))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/string.json
        if  let tests:TestGroup = tests / "string"
        {

            TestValidBSON(tests / "empty",
                canonical: "0D000000026100010000000000",
                expected: ["a": ""])

            TestValidBSON(tests / "single-character",
                canonical: "0E00000002610002000000620000",
                expected: ["a": "b"])

            TestValidBSON(tests / "multiple-character",
                canonical: "190000000261000D0000006162616261626162616261620000",
                expected: ["a": "abababababab"])

            TestValidBSON(tests / "utf-8-double-code-unit",
                canonical: "190000000261000D000000C3A9C3A9C3A9C3A9C3A9C3A90000",
                expected: ["a": "\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}"])

            TestValidBSON(tests / "utf-8-triple-code-unit",
                canonical: "190000000261000D000000E29886E29886E29886E298860000",
                expected: ["a": "\u{2606}\u{2606}\u{2606}\u{2606}"])

            TestValidBSON(tests / "utf-8-null-bytes",
                canonical: "190000000261000D0000006162006261620062616261620000",
                expected: ["a": "ab\u{00}bab\u{00}babab"])

            TestValidBSON(tests / "escaped",
                canonical:
                    """
                    3200000002610026000000\
                    61625C220102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F6162\
                    0000
                    """,
                expected:
                [
                    "a":
                    """
                    ab\\\"\u{01}\u{02}\u{03}\u{04}\u{05}\u{06}\u{07}\u{08}\
                    \t\n\u{0b}\u{0c}\r\u{0e}\u{0f}\u{10}\
                    \u{11}\u{12}\u{13}\u{14}\u{15}\u{16}\u{17}\u{18}\u{19}\
                    \u{1a}\u{1b}\u{1c}\u{1d}\u{1e}\u{1f}ab
                    """
                ])

            TestInvalidBSON(tests / "missing-trailing-null-byte",
                invalid: "0C000000_02_6100_00000000_00",
                //                         ^~~~~~~~
                catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: 0))

            TestInvalidBSON(tests / "invalid-length-negative",
                invalid: "0C000000_02_6100_FFFFFFFF_00",
                //                         ^~~~~~~~
                catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: -1))

            TestInvalidBSON(tests / "invalid-length-over",
                invalid: "10000000_02_6100_05000000_62006200_00",
                //                         ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(5), encountered: 4))

            TestInvalidBSON(tests / "invalid-length-over-document",
                invalid: "12000000_02_00_FFFFFF00_666F6F6261720000",
                //                       ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0xffffff), encountered: 7))

            TestInvalidBSON(tests / "invalid-length-under",
                invalid: "0E000000_02_6100_01000000_00_00_00",
                //                                     ^~
                catching: BSON.TypeError.init(invalid: 0x00))

            TestValidBSON(tests / "invalid-utf-8",
                canonical: "0E00000002610002000000E90000",
                expected: ["a": .string(.init(slice: [0xe9]))])
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/symbol.json
        if  let tests:TestGroup = tests / "symbol"
        {

            TestValidBSON(tests / "empty",
                degenerate: "0D0000000E6100010000000000",
                canonical: "0D000000026100010000000000",
                expected: ["a": ""])

            TestValidBSON(tests / "single-character",
                degenerate: "0E0000000E610002000000620000",
                canonical: "0E00000002610002000000620000",
                expected: ["a": "b"])

            TestValidBSON(tests / "multiple-character",
                degenerate: "190000000E61000D0000006162616261626162616261620000",
                canonical: "190000000261000D0000006162616261626162616261620000",
                expected: ["a": "abababababab"])

            TestValidBSON(tests / "utf-8-double-code-unit",
                degenerate: "190000000E61000D000000C3A9C3A9C3A9C3A9C3A9C3A90000",
                canonical: "190000000261000D000000C3A9C3A9C3A9C3A9C3A9C3A90000",
                expected: ["a": "\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}"])

            TestValidBSON(tests / "utf-8-triple-code-unit",
                degenerate: "190000000E61000D000000E29886E29886E29886E298860000",
                canonical: "190000000261000D000000E29886E29886E29886E298860000",
                expected: ["a": "\u{2606}\u{2606}\u{2606}\u{2606}"])

            TestValidBSON(tests / "utf-8-null-bytes",
                degenerate: "190000000E61000D0000006162006261620062616261620000",
                canonical: "190000000261000D0000006162006261620062616261620000",
                expected: ["a": "ab\u{00}bab\u{00}babab"])
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/code.json
        if  let tests:TestGroup = tests / "javascript"
        {

            TestValidBSON(tests / "empty",
                canonical: "0D0000000D6100010000000000",
                expected: ["a": .javascript(.init(from: ""))])

            TestValidBSON(tests / "single-character",
                canonical: "0E0000000D610002000000620000",
                expected: ["a": .javascript(.init(from: "b"))])

            TestValidBSON(tests / "multiple-character",
                canonical: "190000000D61000D0000006162616261626162616261620000",
                expected: ["a": .javascript(.init(from: "abababababab"))])

            TestValidBSON(tests / "utf-8-double-code-unit",
                canonical: "190000000D61000D000000C3A9C3A9C3A9C3A9C3A9C3A90000",
                expected: ["a": .javascript(.init(from: "\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}"))])

            TestValidBSON(tests / "utf-8-triple-code-unit",
                canonical: "190000000D61000D000000E29886E29886E29886E298860000",
                expected: ["a": .javascript(.init(from: "\u{2606}\u{2606}\u{2606}\u{2606}"))])

            TestValidBSON(tests / "utf-8-null-bytes",
                canonical: "190000000D61000D0000006162006261620062616261620000",
                expected: ["a": .javascript(.init(from: "ab\u{00}bab\u{00}babab"))])

            TestInvalidBSON(tests / "missing-trailing-null-byte",
                invalid: "0C000000_0D_6100_00000000_00",
                //                         ^~~~~~~~
                catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: 0))

            TestInvalidBSON(tests / "invalid-length-negative",
                invalid: "0C0000000D6100FFFFFFFF00",
                catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: -1))

            TestInvalidBSON(tests / "invalid-length-over",
                invalid: "10000000_0D_6100_05000000_6200620000",
                //                         ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(5), encountered: 4))

            TestInvalidBSON(tests / "invalid-length-over-document",
                invalid: "12000000_0D_00_FFFFFF00_666F6F6261720000",
                //                       ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0xffffff), encountered: 7))

            TestInvalidBSON(tests / "invalid-length-under",
                invalid: "0E000000_0D_6100_01000000_00_00_00",
                //                                     ^~
                catching: BSON.TypeError.init(invalid: 0x00))
        }

        // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/code_w_scope.json
        if  let tests:TestGroup = tests / "javascript-scope"
        {

            TestValidBSON(tests / "empty",
                canonical: "160000000F61000E0000000100000000050000000000",
                expected: ["a": .javascriptScope([:], .init(from: ""))])

            TestValidBSON(tests / "empty-scope",
                canonical: "1A0000000F610012000000050000006162636400050000000000",
                expected: ["a": .javascriptScope([:], .init(from: "abcd"))])

            TestValidBSON(tests / "empty-code",
                canonical: "1D0000000F61001500000001000000000C000000107800010000000000",
                expected: ["a": .javascriptScope(["x": .int32(1)], .init(from: ""))])

            TestValidBSON(tests / "non-empty",
                canonical: "210000000F6100190000000500000061626364000C000000107800010000000000",
                expected: ["a": .javascriptScope(["x": .int32(1)], .init(from: "abcd"))])

            TestValidBSON(tests / "unicode",
                canonical: "1A0000000F61001200000005000000C3A9006400050000000000",
                expected: ["a": .javascriptScope([:], .init(from: "\u{e9}\u{00}d"))])

            // note: we do not validate the redundant field length,
            // so those tests are not included

            // note: the length is actually too short, but because we use the component-wise
            // length headers instead of the field length, this manifests itself as a
            // frameshift error.
            TestInvalidBSON(tests / "invalid-length-frameshift-clips-scope",
                invalid: "28000000_0F_6100_20000000_04000000_61626364_00130000_0010780001000000107900010000000000",
                //                                                    ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0x00_00_13_00 - 4), encountered: 16))

            TestInvalidBSON(tests / "invalid-length-over",
                invalid: "28000000_0F_6100_20000000_06000000_616263640013_00000010_780001000000107900010000000000",
                //                                                        ^~~~~~~~
                catching: BSON.InputError.init(expected: .bytes(0x10_00_00_00 - 4), encountered: 14))
            // note: frameshift
            TestInvalidBSON(tests / "invalid-length-frameshift",
                invalid: "28000000_0F_6100_20000000_FF000000_61626364001300000010780001000000107900010000000000",
                catching: BSON.InputError.init(expected: .bytes(255), encountered: 24))

            TestInvalidBSON(tests / "invalid-scope",
                invalid: "1C000000_0F_00_15000000_01000000_00_0C000000_02_00000000_00000000",
                //                                                        ^~~~~~~~
                catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: 0))
        }
    }
}
