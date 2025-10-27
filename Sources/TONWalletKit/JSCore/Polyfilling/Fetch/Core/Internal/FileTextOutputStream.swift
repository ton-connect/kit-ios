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

import Darwin

// MARK: - StandardTextOutputStream

/// A `TextOutputStream` that writes to a FILE pointer.
struct FileTextOutputStream: TextOutputStream {
  private let file: UnsafeMutablePointer<FILE>

  /// Creates an output stream that writes to the specified FILE pointer.
  ///
  /// - Parameter file: A FILE pointer.
  public init(file: UnsafeMutablePointer<FILE>) {
    self.file = file
  }

  func write(_ string: String) {
    guard !string.isEmpty else { return }
    fputs(string, self.file)
  }
}

extension TextOutputStream where Self == FileTextOutputStream {
  /// An output stream that writes to stdout.
  static var stdout: Self { FileTextOutputStream(file: _stdout) }

  /// An output stream that writed to stderr.
  static var stderr: Self { FileTextOutputStream(file: _stderr) }
}

private nonisolated(unsafe) let _stdout = stdout
private nonisolated(unsafe) let _stderr = stderr
