//
//  UIApplication.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 29.10.2025.
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

import UIKit

extension UIApplication {
    func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }
        
        return getTopViewController(from: rootViewController)
    }
    
    private func getTopViewController(from viewController: UIViewController) -> UIViewController? {
        if let presented = viewController.presentedViewController {
            return getTopViewController(from: presented)
        }
        
        if let navigationController = viewController as? UINavigationController {
            guard let topViewController = navigationController.topViewController else {
                return navigationController
            }
            return getTopViewController(from: topViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController {
            guard let selectedViewController = tabBarController.selectedViewController else {
                return tabBarController
            }
            return getTopViewController(from: selectedViewController)
        }
        
        if viewController.isBeingDismissed || viewController.isMovingFromParent {
            return viewController.presentingViewController
        }
        return viewController
    }
}
