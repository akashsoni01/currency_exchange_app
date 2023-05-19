//
//  Models.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import Foundation
import IdentifiedCollections

// Sort the rates by currency code
struct CurrencyExchange: Codable, Equatable {
    let disclaimer: String?
    let license: String?
    var base: String?
    let timestamp: Int
    var lastFetchedTime: Date? = Date()
//    let rates: IdentifiedArrayOf<ItemModel>
    var currencyValue = 1.0
    var currencyExchangeValue = 1.0
    var selectedCurrency: String = "USD"
    var oldSelectedCurrency: String = ""

    var rates: [String: Double]?
    var sortedKeys: [String] {
        rates?.keys.sorted() ?? []
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disclaimer = try container.decodeIfPresent(String.self, forKey: .disclaimer)
        self.license = try container.decodeIfPresent(String.self, forKey: .license)
        self.base = try container.decodeIfPresent(String.self, forKey: .base)
        self.timestamp = try container.decode(Int.self, forKey: .timestamp)
        self.lastFetchedTime = Date()
//        self.rates = IdentifiedArrayOf(
//            uniqueElements: (try container.decodeIfPresent([String: Double].self, forKey: .rates)?
//            .sorted { $0.key < $1.key }
//            .map { ItemModel(title: $0.key, rate: $0.value) } ?? [])
//            )
        self.rates = try container.decodeIfPresent([String: Double].self, forKey: .rates)
        self.currencyValue = try container.decodeIfPresent(Double.self, forKey: .currencyValue) ?? 1.0
        self.currencyExchangeValue = try container.decodeIfPresent(Double.self, forKey: .currencyExchangeValue) ?? 1.0
        self.selectedCurrency = try container.decodeIfPresent(String.self, forKey: .selectedCurrency) ?? ""
        self.oldSelectedCurrency = try container.decodeIfPresent(String.self, forKey: .oldSelectedCurrency) ?? ""        
    }
    
    init(disclaimer: String?, license: String?, base: String?, timestamp: Int, lastFetchedTime: Date? = nil, rates: [ItemModel] = []) {
        self.disclaimer = disclaimer
        self.license = license
        self.base = base
        self.timestamp = timestamp
        self.lastFetchedTime = lastFetchedTime
//        self.rates = []
        self.rates = [:]
    }
}

