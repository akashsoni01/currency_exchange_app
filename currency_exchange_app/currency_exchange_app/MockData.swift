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
    "AFN": 23.964651048793936,
    "ALL": 27.85890811053696,
    "AMD": 105.202099630318,
    "ANG": 0.49066971671330245,
    "USD": 0.27232559247836713
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
