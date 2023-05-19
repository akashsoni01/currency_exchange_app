//
//  ApiClient.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

struct CurrencyApiClient: Sendable {
    var getCurrencyExchangeRates: @Sendable (_ base: String) async throws -> CurrencyExchange

    enum YourApiError: Error {
        case problemWhileParsing
    }

}

extension CurrencyApiClient {
    static func `default`() -> CurrencyApiClient {
        return CurrencyApiClient { base in
            return .mock
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

