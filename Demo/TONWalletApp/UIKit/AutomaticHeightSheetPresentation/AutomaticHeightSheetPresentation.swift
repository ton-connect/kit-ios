//
//  AutomaticHeightSheetPresentation.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 03.10.2025.
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

/// An extension to the `View` protocol, providing a method to apply automatic height presentation detents to sheets.
public extension View {

    /// Applies automatic height-based presentation detents to the view when presented as a sheet.
    ///
    /// This modifier dynamically adjusts the sheet's height based on the content's intrinsic height,
    /// ensuring that the sheet resizes appropriately as the content changes. Additional detents can be
    /// provided to offer fixed heights alongside the automatic adjustment.
    ///
    /// - Parameter detents: A set of additional `PresentationDetent` values to include alongside the automatic height detent.
    ///                      Defaults to an empty set.
    /// - Returns: A view modified to present a sheet with automatic height detents.
    func automaticHeightPresentationDetents(_ detents: Set<PresentationDetent> = []) -> some View {
        self.modifier(AutomaticHeightSheetPresentationModifier(detents: detents))
    }
}

/// A view modifier that adjusts the sheet's presentation detents based on the content's height.
struct AutomaticHeightSheetPresentationModifier: ViewModifier {
    /// The current automatic height of the content.
    @State private var automaticHeight: CGFloat = 0

    /// A set of additional presentation detents to include.
    let detents: Set<PresentationDetent>

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            automaticHeight = geometry.size.height
                        }
                        .onChange(of: geometry.size.height) { newHeight in
                            automaticHeight = newHeight
                        }
                }
            )
            .presentationDetents(Set<PresentationDetent>([.height(automaticHeight)]).union(detents))
    }
}
