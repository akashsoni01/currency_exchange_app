//
//  ApiClient.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

struct CurrencyExchange: Codable {
    let disclaimer: String?
    let license: String?
    let base: String?
    let rates: [String: Double]?
    
}


struct CurrencyApiClient: Sendable {
    var getCurrencyExchangeRates: @Sendable (_ base: String) async throws -> CurrencyExchange

    enum YourApiError: Error {
        case problemWhileParsing
    }

}

extension CurrencyApiClient {
    static func `default`() -> CurrencyApiClient {
        return CurrencyApiClient { base in
            return CurrencyExchange(
                disclaimer: "disclaimer",
                license: "license",
                base: "USD",
                rates: [
                    "AED": 3.672075,
                    "AFN": 87.999996,
                    "ALL": 102.3,
                    "AMD": 386.31,
                    "ANG": 1.801776,
                    "AOA": 526.5,
                    "ARS": 231.6347,
                    "AUD": 1.500945,
                    "AWG": 1.8,
                    "AZN": 1.7,
                    "BAM": 1.805376,
                    "BBD": 2,
                    "BDT": 107.373626,
                    "BGN": 1.80297,
                    "BHD": 0.376988,
                    "BIF": 2083.541622,
                    "BMD": 1,
                    "BND": 1.342817,
                    "BOB": 6.908393,
                    "BRL": 4.9345,
                    "BSD": 1,
                    "BTC": 0.000036539057,
                    "BTN": 82.410653,
                    "BWP": 13.546869,
                    "BYN": 2.523446,
                    "BZD": 2.015194,
                    "CAD": 1.344513,
                    "CDF": 2307,
                    "CHF": 0.898353,
                    "CLF": 0.028778,
                    "CLP": 793.99,
                    "CNH": 7.011472,
                    "CNY": 6.9986,
                    "COP": 4535.926189,
                    "CRC": 533.821556,
                    "CUC": 1,
                    "CUP": 25.75,
                    "CVE": 102.125,
                    "CZK": 21.836101,
                    "DJF": 178,
                    "DKK": 6.869312,
                    "DOP": 54.45,
                    "DZD": 136.353006,
                    "EGP": 30.9008,
                    "ERN": 15,
                    "ETB": 54.24,
                    "EUR": 0.922513,
                    "FJD": 2.2174,
                    "FKP": 0.800489,
                    "GBP": 0.800489,
                    "GEL": 2.5475,
                    "GGP": 0.800489,
                    "GHS": 10.85,
                    "GIP": 0.800489,
                    "GMD": 59.65,
                    "GNF": 8650,
                    "GTQ": 7.79825,
                    "GYD": 211.451824,
                    "HKD": 7.829972,
                    "HNL": 24.669999,
                    "HRK": 6.950524,
                    "HTG": 143.964804,
                    "HUF": 340.939672,
                    "IDR": 14846.780385,
                    "ILS": 3.6465,
                    "IMP": 0.800489,
                    "INR": 82.4465,
                    "IQD": 1310,
                    "IRR": 42255,
                    "ISK": 139.76,
                    "JEP": 0.800489,
                    "JMD": 154.728026,
                    "JOD": 0.7095,
                    "JPY": 137.61586667,
                    "KES": 137.4,
                    "KGS": 87.5181,
                    "KHR": 4116,
                    "KMF": 452.8504,
                    "KPW": 900,
                    "KRW": 1334.000222,
                    "KWD": 0.307079,
                    "KYD": 0.833156,
                    "KZT": 450.233166,
                    "LAK": 17565,
                    "LBP": 15120,
                    "LKR": 310.406211,
                    "LRD": 167.249962,
                    "LSL": 19.25,
                    "LYD": 4.775,
                    "MAD": 10.1245,
                    "MDL": 17.677307,
                    "MGA": 4405,
                    "MKD": 56.975252,
                    "MMK": 2099.471443,
                    "MNT": 3519,
                    "MOP": 8.060776,
                    "MRU": 34.48,
                    "MUR": 45.400003,
                    "MVR": 15.355,
                    "MWK": 1026,
                    "MXN": 17.577238,
                    "MYR": 4.525,
                    "MZN": 63.850001,
                    "NAD": 19.25,
                    "NGN": 461.25,
                    "NIO": 36.575,
                    "NOK": 10.769661,
                    "NPR": 131.856702,
                    "NZD": 1.598674,
                    "OMR": 0.384993,
                    "PAB": 1,
                    "PEN": 3.6535,
                    "PGK": 3.525,
                    "PHP": 56.019496,
                    "PKR": 285,
                    "PLN": 4.17001,
                    "PYG": 7181.575939,
                    "QAR": 3.641,
                    "RON": 4.5774,
                    "RSD": 108.204567,
                    "RUB": 80.300008,
                    "RWF": 1124.25,
                    "SAR": 3.750242,
                    "SBD": 8.326972,
                    "SCR": 13.255041,
                    "SDG": 601,
                    "SEK": 10.445218,
                    "SGD": 1.342242,
                    "SHP": 0.800489,
                    "SLL": 17665,
                    "SOS": 569,
                    "SRD": 37.4815,
                    "SSP": 130.26,
                    "STD": 22823.990504,
                    "STN": 22.85,
                    "SVC": 8.748108,
                    "SYP": 2512.53,
                    "SZL": 19.25,
                    "THB": 34.2525,
                    "TJS": 10.922257,
                    "TMT": 3.51,
                    "TND": 3.079,
                    "TOP": 2.35615,
                    "TRY": 19.7631,
                    "TTD": 6.785622,
                    "TWD": 30.7635,
                    "TZS": 2360,
                    "UAH": 36.924267,
                    "UGX": 3723.744087,
                    "USD": 1,
                    "UYU": 38.962419,
                    "UZS": 11455,
                    "VES": 25.615839,
                    "VND": 23454.908262,
                    "VUV": 118.979,
                    "WST": 2.72551,
                    "XAF": 605.128795,
                    "XAG": 0.04207426,
                    "XAU": 0.00050423,
                    "XCD": 2.70255,
                    "XDR": 0.743363,
                    "XOF": 605.128795,
                    "XPD": 0.00067324,
                    "XPF": 110.085072,
                    "XPT": 0.00092946,
                    "YER": 250.324978,
                    "ZAR": 19.265166,
                    "ZMW": 18.57069,
                    "ZWL": 322
                ]
            )
        }
    }
}

extension CurrencyApiClient: TestDependencyKey {
    static var previewValue: CurrencyApiClient {
        .default()
    }
    
    static let testValue = Self(
        getCurrencyExchangeRates:  XCTUnimplemented("\(Self.self).getStoreFrontNameAsync")
    )
}

extension CurrencyApiClient: DependencyKey {
    static let liveValue = CurrencyApiClient { baseCurrency in
        let baseUrl = "https://openexchangerates.org/api/latest.json"
        let accessKey = "c93e17ac5f294003b681de539538b240"
        let url = URL(string: "\(baseUrl)?app_id=\(accessKey)&base=\(baseCurrency)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(CurrencyExchange.self, from: data)
    }
}



extension DependencyValues {
    var currencyApiClient: CurrencyApiClient {
        get { self[CurrencyApiClient.self] }
        set { self[CurrencyApiClient.self] = newValue }
    }
}

