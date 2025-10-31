//
//  Copyright (c) 2025 TON Connect
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

// MARK: - Lock

/// A simple lock data type.
package struct Lock<Value: ~Copyable>: ~Copyable {
  private let lock = NSLock()
  private var value: UnsafeMutablePointer<Value>

  /// Creates a lock by consuming the specified value.
  ///
  /// - Parameter value: The initial value of the lock.
  package init(_ value: consuming sending Value) {
    self.value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    self.value.initialize(to: value)
  }

  deinit { self.value.deallocate() }
}

// MARK: - WithLock

extension Lock {
  /// Calls the specified closure with the lock acquired and gives up ownership of the value.
  ///
  /// > Warning: Do not call this method from within `body`, this will cause a deadlock.
  ///
  /// - Parameter body: A closure with mutable access to the underlying value.
  /// - Returns: Whatever `body` returns.
  package borrowing func withLock<Result: ~Copyable, E: Error>(
    _ body: (inout sending Value) throws(E) -> sending Result
  ) throws(E) -> sending Result {
    self.lock.lock()
    defer { self.lock.unlock() }
    return try body(&self.value.pointee)
  }
}

// MARK: - Sendable

extension Lock: @unchecked Sendable where Value: ~Copyable {}
