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

    var sortedKeys: [String] {
        keyValues.keys.sorted()
    }

    init(selectedKey: Binding<String>, keyValues: [String : Double]) {
        self._selectedKey = selectedKey
        self.keyValues = keyValues
    }
    
    var body: some View {
        Picker("Select Currency", selection: $selectedKey) {
            ForEach(sortedKeys, id: \.self) { key in
                Text(key)
            }
        }
    }
}
