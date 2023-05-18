//
//  Models.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import Foundation

struct CurrencyExchange: Codable {
    let disclaimer: String?
    let license: String?
    let base: String?
    let timestamp: Int
    var lastFetchedTime: Date? = Date()
    let rates: [String: Double]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disclaimer = try container.decodeIfPresent(String.self, forKey: .disclaimer)
        self.license = try container.decodeIfPresent(String.self, forKey: .license)
        self.base = try container.decodeIfPresent(String.self, forKey: .base)
        self.timestamp = try container.decode(Int.self, forKey: .timestamp)
        self.lastFetchedTime = Date()
        self.rates = try container.decodeIfPresent([String : Double].self, forKey: .rates)
    }
    
    init(disclaimer: String?, license: String?, base: String?, timestamp: Int, lastFetchedTime: Date? = nil, rates: [String : Double]?) {
        self.disclaimer = disclaimer
        self.license = license
        self.base = base
        self.timestamp = timestamp
        self.lastFetchedTime = lastFetchedTime
        self.rates = rates
    }
}
