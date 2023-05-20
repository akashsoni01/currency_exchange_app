//
//  CurrencyExchangeView.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import ComposableArchitecture
import SwiftUI

struct CurrencyExchangeView: View {
    private let store: StoreOf<CurrencyExchangeFeature>

    init(store: StoreOf<CurrencyExchangeFeature>) {
        self.store = store
    }
        
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                List {
                        TextField("Enter a value", value: viewStore.binding(\.$model.currencyValue), format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)

                        if let rates = viewStore.model.rates,
                           rates.count > 0,
                           viewStore.model.selectedCurrency.count > 0 {
                            CurrencyPickerView(
                                selectedKey: viewStore.binding(\.$model.selectedCurrency),
                                keyValues: viewStore.model.rates ?? [:]
                            )
                        }
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 120)),
                        ], spacing: 20) {
                            ForEach(viewStore.items, id: \.id) { item in
                                ItemView(item: item)
                                    .frame(minHeight: 50)
                            }
                        }
                    }
                }
                .refreshable {
                    viewStore.send(.refresh)
                }

            }
            .onAppear{
                viewStore.send(.viewWillAppear)
            }
        }
    }
}
