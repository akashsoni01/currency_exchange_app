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
    var currencyValue = 1.0
    var currencyExchangeValue = 1.0
    var selectedCurrency: String = "USD"
    var oldSelectedCurrency: String = "USD"

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
        self.rates = try container.decodeIfPresent([String: Double].self, forKey: .rates)
        self.currencyValue = try container.decodeIfPresent(Double.self, forKey: .currencyValue) ?? 1.0
        self.currencyExchangeValue = try container.decodeIfPresent(Double.self, forKey: .currencyExchangeValue) ?? 1.0
        self.selectedCurrency = try container.decodeIfPresent(String.self, forKey: .selectedCurrency) ?? "USD" // for initial call this will return "" that can impact our picker view
        self.oldSelectedCurrency = try container.decodeIfPresent(String.self, forKey: .oldSelectedCurrency) ?? "USD"
    }
        
    
    init(disclaimer: String?, license: String?, base: String? = nil, timestamp: Int, lastFetchedTime: Date? = nil, currencyValue: Double = 1.0, currencyExchangeValue: Double = 1.0, selectedCurrency: String, oldSelectedCurrency: String, rates: [String : Double]? = nil) {
        self.disclaimer = disclaimer
        self.license = license
        self.base = base
        self.timestamp = timestamp
        self.lastFetchedTime = lastFetchedTime
        self.currencyValue = currencyValue
        self.currencyExchangeValue = currencyExchangeValue
        self.selectedCurrency = selectedCurrency
        self.oldSelectedCurrency = oldSelectedCurrency
        self.rates = rates
    }
}

