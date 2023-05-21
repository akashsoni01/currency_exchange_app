//
//  currency_exchange_appTests.swift
//  currency_exchange_appTests
//
//  Created by Akash soni on 18/05/23.
//

import XCTest
import ComposableArchitecture
@testable import currency_exchange_app

@MainActor
final class currency_exchange_appTests: XCTestCase {
    
    func test_task() async {
        let currencyExchange = CurrencyExchange.mock
        let testClock = TestClock()
        let testStore = TestStore(
            initialState: CurrencyExchangeFeature.State(
                model: currencyExchange)
        ) {
            CurrencyExchangeFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
            $0.continuousClock = testClock
            $0.currencyApiClient = .default()
            $0.currencyApiClient.getCurrencyExchangeRates = { _ in currencyExchange }
            $0.dataManager = .mock(
                initialData: try! JSONEncoder().encode(currencyExchange)
              )
            $0.calendar = .current
        }
        
        await testStore.send(.task)
        await testStore.receive(.fetchCurrencies)
        await testStore.receive(.receiveCurrency(.success(currencyExchange))) {
            $0.model = currencyExchange
            $0.model.lastFetchedTime = Date(timeIntervalSince1970: 1_234_567_890)
            $0.items = mockIdntifiedArray()
        }
        await testClock.advance(by: .seconds(1))


    }
    
    func test_receiveCurrency_success() async throws {
        let currencyExchange = CurrencyExchange.mock
        let testClock = TestClock()
        let testStore = TestStore(
            initialState: CurrencyExchangeFeature.State(
                model: currencyExchange)
        ) {
            CurrencyExchangeFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
            $0.continuousClock = testClock
            $0.dataManager = .mock(
                initialData: try! JSONEncoder().encode(currencyExchange)
              )
        }
        
        await testStore.send(
            .receiveCurrency(
            .success(currencyExchange)
            )
        ) {
            $0.model = currencyExchange
            $0.model.lastFetchedTime = Date(timeIntervalSince1970: 1_234_567_890)
            $0.items = mockIdntifiedArray()
        }
        await testClock.advance(by: .seconds(1))

    }
    
    func test_receiveCurrency_fail() async throws {
        let currencyExchange = CurrencyExchange.mock
        struct RefreshFailure: Error {}
        let failure = RefreshFailure()
        let testStore = TestStore(
            initialState: CurrencyExchangeFeature.State(
                model: currencyExchange)
        ) {
            CurrencyExchangeFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.dataManager = .mock(
                initialData: try! JSONEncoder().encode(currencyExchange)
              )
        }
        await testStore.send(.receiveCurrency(.failure(failure)))
    }

}






