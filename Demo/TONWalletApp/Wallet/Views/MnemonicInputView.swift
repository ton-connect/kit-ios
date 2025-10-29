//
//  MnemonicInputView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 12.09.2025.
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
import SwiftUI
import TONWalletKit

struct MnemonicInputView: View {
    @Binding var mnemonic: TONMnemonic
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 12) {
                ForEach(0..<TONMnemonicLenght.bits256.rawValue, id: \.self) { index in
                    HStack(spacing: 8) {
                        
                        TextField(
                            "\(index + 1)",
                            text: Binding(
                                get: { mnemonic.value[index]
                                },
                                set: {
                                    mnemonic.update(
                                        word: $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
                                        at: index
                                    )
                                }
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding()
    }
}
