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
import Security

// MARK: - Installer

public struct JSCryptoInstaller: JSContextInstallable {
  public func install(in context: JSContext) throws {
    let randomUUID: @convention(block) () -> String = { "\(UUID())".lowercased() }
    let randomBytes: @convention(block) (Int) -> [UInt8] = { self.randomBytes(count: $0) }
    context.setObject(randomUUID, forPath: "_jsCoreExtrasRandomUUID")
    context.setObject(randomBytes, forPath: "_jsCoreExtrasRandomBytes")
    try context.install([.jsCoreExtrasBundled(path: "Crypto.js")])
  }

  private func randomBytes(count: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)
    let result = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
    if result != errSecSuccess {
      let errorMessage =
        SecCopyErrorMessageString(result, nil) as? String ?? "Unknown Security Framework Error"
      JSContext.current()?.exception = JSValue(
        newErrorFromMessage: errorMessage,
        in: .current()
      )
    }
    return bytes
  }
}

extension JSContextInstallable where Self == JSCryptoInstaller {
  /// An installable that installs web browser crypto operations.
  ///
  /// `crypto.subtle` is not supported, only `crypto.getRandomValues` and `crypto.randomUUID`
  /// are supported.
  public static var crypto: Self { JSCryptoInstaller() }
}
