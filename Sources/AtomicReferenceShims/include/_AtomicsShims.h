//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Atomics open source project
//
// Copyright (c) 2020-2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#ifndef SWIFTATOMIC_HEADER_INCLUDED
#define SWIFTATOMIC_HEADER_INCLUDED 1

// Swift-importable shims for C atomics.
//
// Swift cannot import C's atomic types or any operations over them, so we need
// to meticulously wrap all of them in tiny importable types and functions.
//
// This file defines an atomic storage representation and 56 atomic operations
// for each of the 10 standard integer types in the Standard Library, as well as
// Bool and a double-word integer type. To prevent us from having to manually
// write/maintain a thousand or so functions, we use the C preprocessor to stamp
// these out.
//
// Supporting double-wide integers is tricky, because neither Swift nor C has
// standard integer representations for these on platforms where `Int` has a bit
// width of 64. Standard C can model 128-bit atomics through `_Atomic(struct
// pair)` where `pair` is a struct of two `intptr_t`s, but current Swift
// compilers (as of version 5.3) get confused by atomic structs
// (https://reviews.llvm.org/D86218). To work around that, we need to use the
// nonstandard `__uint128_t` type. The Swift compiler does seem to be able to
// deal with `_Atomic(__uint128_t)`, but it refuses to directly import
// `__uint128_t`, so that too needs to be wrapped in a dummy struct (which we
// call `_sa_dword`). We want to stamp out 128-bit atomics from the same code as
// regular atomics, so this requires all atomic operations to distinguish
// between the "exported" C type and the corresponding "internal"
// representation, and to explicitly convert between them as needed. This is
// done using the `SWIFTATOMIC_ENCODE_<swiftType>` and
// `SWIFTATOMIC_DECODE_<swiftType>` family of macros.
//
// In the case of compare-and-exchange, the conversion of the `expected`
// argument needs to go through a temporary stack variable that would result in
// slightly worse codegen for the regular single-word case, so we distinguish
// between `SIMPLE` and `COMPLEX` cmpxchg variants. The single variant assumes
// that the internal representation is identical to the exported type, and does
// away with the comparisons.
//
// FIXME: Upgrading from the preprocessor to gyb would perhaps make things more
// readable here.
//
// FIXME: Eliminate the encoding/decoding mechanism once the package requires a
// compiler that includes https://reviews.llvm.org/D86218.


#include <stdbool.h>
#include <stdint.h>
#include <assert.h>
// The atomic primitives are only needed when this is compiled using Swift's
// Clang Importer. This allows us to continue reling on some Clang extensions
// (see https://github.com/apple/swift-atomics/issues/37).
#if defined(__swift__)
#include <stdatomic.h>
#endif

#if defined(__linux__) && defined(__x86_64__)
#define ENABLE_DOUBLEWIDE_ATOMICS 1
#endif

#if ENABLE_DOUBLEWIDE_ATOMICS
extern void _sa_retain_n(void *object, uint32_t n);
extern void _sa_release_n(void *object, uint32_t n);
#endif

#endif //SWIFTATOMIC_HEADER_INCLUDED
