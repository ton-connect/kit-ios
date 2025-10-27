//
//  View+Widget.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 30.09.2025.
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

import SwiftUI

extension View {
    
    public func widget(style: WidgetModifier.Style = .regular) -> some View {
        self.modifier(WidgetModifier(style: style))
    }
}

public struct WidgetModifier: ViewModifier {
    private let style: Style
    
    init(style: Style) {
        self.style = style
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(style.edgeInsets)
            .background(style.backgroundColor)
            .border(
                style.borderColor,
                width: style.borderWidth,
                cornerRadius: style.cornerRadius
            )
    }
}

public extension WidgetModifier {
    
    enum Style {
        case regular
        case block(BlockType)
        
        var edgeInsets: EdgeInsets {
            let inset: CGFloat = AppSpacing.spacing(4.0)
            return EdgeInsets(
                top: inset,
                leading: inset,
                bottom: inset,
                trailing: inset
            )
        }
        
        var backgroundColor: Color {
            switch self {
            case .regular: .white
            case .block(let type): type.backgroundColor
            }
        }
        
        var borderColor: Color {
            switch self {
            case .regular: .clear
            case .block(let type): type.borderColor
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .regular: 0.0
            case .block: 1.0
            }
        }
        
        var cornerRadius: CGFloat {
            return AppRadius.standard
        }
    }
    
    enum BlockType {
        case regular
        case warning
        
        var backgroundColor: Color {
            switch self {
            case .regular: .TON.gray50
            case .warning: .TON.yellow50
            }
        }
        
        var borderColor: Color {
            switch self {
            case .regular: .clear
            case .warning: .clear
            }
        }
    }
}
