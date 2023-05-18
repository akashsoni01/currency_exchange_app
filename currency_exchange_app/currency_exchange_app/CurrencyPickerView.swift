//
//  CurrencyPickerView.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import SwiftUI

struct CurrencyPickerView: View {
    @Binding var selectedKey: ItemModel
    var keyValues: [ItemModel]

    var body: some View {
        Picker("Select Key", selection: $selectedKey) {
            ForEach(keyValues, id: \.id) { key in
                Text(key.title)
            }
        }
    }
}
