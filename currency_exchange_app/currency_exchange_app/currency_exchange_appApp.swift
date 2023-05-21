//
//  currency_exchange_appApp.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct currency_exchange_appApp: App {

    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                NavigationView {
                    CurrencyExchangeView(store:
                                            Store(initialState: CurrencyExchangeFeature.State(model: CurrencyExchange(selectedCurrency: "USD")), reducer: CurrencyExchangeFeature())
                    )
                }
    //            ItemView(item: ItemModel(title: "USD", rate: 1.5))
            }
        }
    }
}
