//
//  TONTextFieldStyle.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 06.10.2025.
//

import SwiftUI

struct TONTextFieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.TON.gray100)
            .cornerRadius(AppRadius.standard)
            .textLG()
    }
}
