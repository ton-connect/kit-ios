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

import JavaScriptCore

/// A data type for passing `JSValue` across Sendable boundaries.
///
/// The JavaScriptCore API is thread-safe, but `JSValue` does not conform to Sendable because it
/// is an open class that can be subclassed. Therefore, this type exists as an honorary mechanism
/// to avoid Sendable errors with `JSValue`. Do not construct this type with a non-thread-safe
/// `JSValue` subclass instance.
public struct UnsafeJSValueTransfer: @unchecked Sendable {
  /// The `JSValue`.
  public let value: JSValue

  /// Creates a transfer.
  ///
  /// - Parameter value: A `JSValue`.
  public init(value: JSValue) {
    self.value = value
  }
}
