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

enum JSFetchLogger {
    static func logRequest(_ request: URLRequest) {
        #if DEBUG
        var lines: [String] = []
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<unknown>"
        lines.append("→ \(method) \(url)")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            lines.append("  headers:")
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                lines.append("    \(key): \(value)")
            }
        }
        if let body = request.httpBody, !body.isEmpty {
            lines.append("  body:")
            lines.append(formatBody(body))
        }
        print(lines.joined(separator: "\n"))
        #endif
    }

    static func logResponse(_ response: URLResponse, data: Data) {
        #if DEBUG
        var lines: [String] = []
        if let http = response as? HTTPURLResponse {
            let url = http.url?.absoluteString ?? "<unknown>"
            lines.append("← \(http.statusCode) \(url)")
            if !http.allHeaderFields.isEmpty {
                lines.append("  headers:")
                let sorted = http.allHeaderFields
                    .compactMap { key, value -> (String, String)? in
                        guard let key = key.base as? String, let value = value as? String else { return nil }
                        return (key, value)
                    }
                    .sorted { $0.0 < $1.0 }
                for (key, value) in sorted {
                    lines.append("    \(key): \(value)")
                }
            }
        } else {
            lines.append("← \(response)")
        }
        if !data.isEmpty {
            lines.append("  body:")
            lines.append(formatBody(data))
        }
        print(lines.joined(separator: "\n"))
        #endif
    }

    #if DEBUG
    private static func formatBody(_ data: Data) -> String {
        if let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]),
           let pretty = try? JSONSerialization.data(
               withJSONObject: object,
               options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed]
           ),
           let string = String(data: pretty, encoding: .utf8)
        {
            return indent(string)
        }
        if let string = String(data: data, encoding: .utf8) {
            return indent(string)
        }
        return "    <\(data.count) bytes binary>"
    }

    private static func indent(_ string: String) -> String {
        string.split(separator: "\n", omittingEmptySubsequences: false)
            .map { "    " + $0 }
            .joined(separator: "\n")
    }
    #endif
}
