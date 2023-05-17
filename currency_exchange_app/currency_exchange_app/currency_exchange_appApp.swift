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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                CurrencyExchangeView(store:
                                        Store(initialState: CurrencyExchangeFeature.State(), reducer: CurrencyExchangeFeature())
                )
            }
        }
    }
}
