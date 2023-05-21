//
//  MockData.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import Foundation
import IdentifiedCollections
import Dependencies

extension CurrencyExchange {
    static let mock = CurrencyExchange(
        disclaimer: "disclaimer",
        license: "license",
        timestamp: 0,
        selectedCurrency: "USD",
        oldSelectedCurrency: "USD",
        rates: mockRates
    )
}

let mockRates = [
    "AED": 3.672075,
    "AFN": 87.999996,
    "ALL": 102.3,
    "AMD": 386.31,
    "ANG": 1.801776,
    "USD": 1,
]

let mockRatesBaseAED = [
    "AED": 1.0000,
    "AFN": 1.0000,
    "ALL": 1.0000,
    "AMD": 1.0000,
    "ANG": 1.0000,
    "USD": 1.0000
    ]

func mockIdntifiedArray(_ mockData: [String : Double], value: Double = 1.0
) -> IdentifiedArrayOf<ItemModel> {
    let generate = UUIDGenerator.incrementing
    var array = IdentifiedArrayOf<ItemModel>()
    let keys = mockData.keys.sorted()
    keys.forEach { (key) in
        let total = (mockData[key] ?? 1.0) * value
        array.append(ItemModel(id: generate(), title: key, rate: total))
    }
    return array

}
