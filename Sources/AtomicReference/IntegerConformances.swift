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

import _AtomicsShims
import Atomics

extension DoubleWord: AtomicValue {
  @frozen
  public struct AtomicRepresentation {
    public typealias Value = DoubleWord

    @usableFromInline
    var _storage: _AtomicDoubleWordStorage

    @inline(__always) @_alwaysEmitIntoClient
    public init(_ value: Value) {
      self._storage = _sa_prepare_DoubleWord(value)
    }

    @inline(__always) @_alwaysEmitIntoClient
    public func dispose() -> Value {
      // Work around https://github.com/apple/swift-atomics/issues/41
      #if compiler(>=5.5) && arch(arm64) && DEBUG
      var copy = self // This is not great
      var expected = DoubleWord(high: 0, low: 0)
      withUnsafeMutablePointer(to: &copy) { pointer in
        _ = _sa_cmpxchg_strong_relaxed_relaxed_DoubleWord(
          pointer._extract,
          &expected,
          DoubleWord(high: 0, low: 0))
      }
      return expected
      #else
      return _sa_dispose_DoubleWord(_storage)
      #endif
    }
  }
}

extension UnsafeMutablePointer
where Pointee == DoubleWord.AtomicRepresentation {
  @inlinable @inline(__always)
  internal var _extract: UnsafeMutablePointer<_AtomicDoubleWordStorage> {
    // `DoubleWord` is layout-compatible with its only stored property.
    return UnsafeMutableRawPointer(self)
      .assumingMemoryBound(to: _AtomicDoubleWordStorage.self)
  }
}

extension DoubleWord.AtomicRepresentation: AtomicStorage {
  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicLoad(
    at pointer: UnsafeMutablePointer<Self>,
    ordering: AtomicLoadOrdering
  ) -> Value {
    // Work around https://github.com/apple/swift-atomics/issues/41
    #if compiler(>=5.5) && arch(arm64) && DEBUG
    let (_, original) = atomicCompareExchange(
      expected: DoubleWord(high: 0, low: 0),
      desired: DoubleWord(high: 0, low: 0),
      at: pointer,
      successOrdering: .relaxed, // Note: this relies on the FIXME below.
      failureOrdering: ordering)
    return original
    #else
    switch ordering {
    case .relaxed:
      return _sa_load_relaxed_DoubleWord(pointer._extract)
    case .acquiring:
      return _sa_load_acquire_DoubleWord(pointer._extract)
    case .sequentiallyConsistent:
      return _sa_load_seq_cst_DoubleWord(pointer._extract)
    default:
      fatalError("Unsupported ordering")
    }
    #endif
  }

  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicStore(
    _ desired: Value,
    at pointer: UnsafeMutablePointer<Self>,
    ordering: AtomicStoreOrdering
  ) {
    switch ordering {
    case .relaxed:
      _sa_store_relaxed_DoubleWord(pointer._extract, desired)
    case .releasing:
      _sa_store_release_DoubleWord(pointer._extract, desired)
    case .sequentiallyConsistent:
      _sa_store_seq_cst_DoubleWord(pointer._extract, desired)
    default:
      fatalError("Unsupported ordering")
    }
  }

  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicExchange(
    _ desired: Value,
    at pointer: UnsafeMutablePointer<Self>,
    ordering: AtomicUpdateOrdering
  ) -> Value {
    switch ordering {
    case .relaxed:
      return _sa_exchange_relaxed_DoubleWord(pointer._extract, desired)
    case .acquiring:
      return _sa_exchange_acquire_DoubleWord(pointer._extract, desired)
    case .releasing:
      return _sa_exchange_release_DoubleWord(pointer._extract, desired)
    case .acquiringAndReleasing:
      return _sa_exchange_acq_rel_DoubleWord(pointer._extract, desired)
    case .sequentiallyConsistent:
      return _sa_exchange_seq_cst_DoubleWord(pointer._extract, desired)
    default:
      fatalError("Unsupported ordering")
    }
  }

  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicCompareExchange(
    expected: Value,
    desired: Value,
    at pointer: UnsafeMutablePointer<Self>,
    ordering: AtomicUpdateOrdering
  ) -> (exchanged: Bool, original: Value) {
    var expected = expected
    let exchanged: Bool
    switch ordering {
    case .relaxed:
      exchanged = _sa_cmpxchg_strong_relaxed_relaxed_DoubleWord(
        pointer._extract,
        &expected, desired)
    case .acquiring:
      exchanged = _sa_cmpxchg_strong_acquire_acquire_DoubleWord(
        pointer._extract,
        &expected, desired)
    case .releasing:
      exchanged = _sa_cmpxchg_strong_release_relaxed_DoubleWord(
        pointer._extract,
        &expected, desired)
    case .acquiringAndReleasing:
      exchanged = _sa_cmpxchg_strong_acq_rel_acquire_DoubleWord(
        pointer._extract,
        &expected, desired)
    case .sequentiallyConsistent:
      exchanged = _sa_cmpxchg_strong_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected, desired)
    default:
      fatalError("Unsupported ordering")
    }
    return (exchanged, expected)
  }

  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicCompareExchange(
    expected: Value,
    desired: Value,
    at pointer: UnsafeMutablePointer<Self>,
    successOrdering: AtomicUpdateOrdering,
    failureOrdering: AtomicLoadOrdering
  ) -> (exchanged: Bool, original: Value) {
    var expected = expected
    let exchanged: Bool
    // FIXME: stdatomic.h (and LLVM underneath) doesn't support
    // arbitrary ordering combinations yet, so upgrade the success
    // ordering when necessary so that it is at least as "strong" as
    // the failure case.
    switch (successOrdering, failureOrdering) {
    case (.relaxed, .relaxed):
      exchanged = _sa_cmpxchg_strong_relaxed_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.relaxed, .acquiring):
      exchanged = _sa_cmpxchg_strong_acquire_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.relaxed, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_strong_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiring, .relaxed):
      exchanged = _sa_cmpxchg_strong_acquire_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiring, .acquiring):
      exchanged = _sa_cmpxchg_strong_acquire_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiring, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_strong_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.releasing, .relaxed):
      exchanged = _sa_cmpxchg_strong_release_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.releasing, .acquiring):
      exchanged = _sa_cmpxchg_strong_acq_rel_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.releasing, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_strong_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiringAndReleasing, .relaxed):
      exchanged = _sa_cmpxchg_strong_acq_rel_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiringAndReleasing, .acquiring):
      exchanged = _sa_cmpxchg_strong_acq_rel_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiringAndReleasing, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_strong_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.sequentiallyConsistent, .relaxed):
      exchanged = _sa_cmpxchg_strong_seq_cst_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.sequentiallyConsistent, .acquiring):
      exchanged = _sa_cmpxchg_strong_seq_cst_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.sequentiallyConsistent, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_strong_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    default:
      fatalError("Unsupported ordering")
    }
    return (exchanged, expected)
  }

  @_semantics("atomics.requires_constant_orderings")
  @_transparent @_alwaysEmitIntoClient
  public static func atomicWeakCompareExchange(
    expected: Value,
    desired: Value,
    at pointer: UnsafeMutablePointer<Self>,
    successOrdering: AtomicUpdateOrdering,
    failureOrdering: AtomicLoadOrdering
  ) -> (exchanged: Bool, original: Value) {
    var expected = expected
    let exchanged: Bool
    // FIXME: stdatomic.h (and LLVM underneath) doesn't support
    // arbitrary ordering combinations yet, so upgrade the success
    // ordering when necessary so that it is at least as "strong" as
    // the failure case.
    switch (successOrdering, failureOrdering) {
    case (.relaxed, .relaxed):
      exchanged = _sa_cmpxchg_weak_relaxed_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.relaxed, .acquiring):
      exchanged = _sa_cmpxchg_weak_acquire_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.relaxed, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_weak_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiring, .relaxed):
      exchanged = _sa_cmpxchg_weak_acquire_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiring, .acquiring):
      exchanged = _sa_cmpxchg_weak_acquire_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiring, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_weak_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.releasing, .relaxed):
      exchanged = _sa_cmpxchg_weak_release_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.releasing, .acquiring):
      exchanged = _sa_cmpxchg_weak_acq_rel_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.releasing, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_weak_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiringAndReleasing, .relaxed):
      exchanged = _sa_cmpxchg_weak_acq_rel_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiringAndReleasing, .acquiring):
      exchanged = _sa_cmpxchg_weak_acq_rel_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.acquiringAndReleasing, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_weak_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.sequentiallyConsistent, .relaxed):
      exchanged = _sa_cmpxchg_weak_seq_cst_relaxed_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.sequentiallyConsistent, .acquiring):
      exchanged = _sa_cmpxchg_weak_seq_cst_acquire_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    case (.sequentiallyConsistent, .sequentiallyConsistent):
      exchanged = _sa_cmpxchg_weak_seq_cst_seq_cst_DoubleWord(
        pointer._extract,
        &expected,
        desired)
    default:
      fatalError("Unsupported ordering")
    }
    return (exchanged, expected)
  }
}

