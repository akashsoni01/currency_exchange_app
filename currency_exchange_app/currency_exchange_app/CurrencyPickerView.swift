//
//  CurrencyPickerView.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import SwiftUI

struct CurrencyPickerView: View {
    @Binding var selectedKey: String
    var keyValues: [String: Double]

    var body: some View {
        Picker("Select Key", selection: $selectedKey) {
            ForEach(Array(keyValues.keys), id: \.self) { key in
                Text(key)
            }
        }
    }
}
