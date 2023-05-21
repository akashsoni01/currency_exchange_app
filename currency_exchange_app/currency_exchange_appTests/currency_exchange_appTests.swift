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
    func test_currencyBaseChanged_sameCountry() async throws {
        let currencyExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: "USD",
            timestamp: 0,
            lastFetchedTime: Date(timeIntervalSince1970: 1_234_567_890),
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: mockRates
        )
        
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

        await testStore.send(.currencyBaseChanged("USD"))
    }
    
    func test_currencyBaseChanged_differentCountry() async throws {
        let currencyExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: "USD",
            timestamp: 0,
            lastFetchedTime: Date(timeIntervalSince1970: 1_234_567_890),
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: mockRates
        )
        
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
        
        await testStore.send(.currencyBaseChanged("AED"))
        
        let expectedExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: "AED",
            timestamp: 0,
            lastFetchedTime: Date(timeIntervalSince1970: 1_234_567_890),
            selectedCurrency: "AED",
            oldSelectedCurrency: "USD",
            rates: mockRatesBaseAED
        )
        
        await testStore.receive(.receiveCurrency(.success(expectedExchange))) {
            $0.model = expectedExchange
            $0.model.lastFetchedTime = Date(timeIntervalSince1970: 1_234_567_890)
            $0.model.oldSelectedCurrency = "AED"
            $0.items = mockIdntifiedArray(mockRatesBaseAED)
        }
        await testClock.advance(by: .seconds(1))

    }
    
    
    func test_refresh() async throws {
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
        
        await testStore.send(.refresh)
        await testStore.receive(.fetchCurrencies)
        await testStore.receive(.receiveCurrency(.success(currencyExchange))) {
            $0.model = currencyExchange
            $0.model.lastFetchedTime = Date(timeIntervalSince1970: 1_234_567_890)
            $0.items = mockIdntifiedArray(mockRates)
        }
        await testClock.advance(by: .seconds(1))

    }
    
    func test_fetchCurrencies_fromLocal() async {
        let currencyExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            timestamp: 0,
            lastFetchedTime: Date(timeIntervalSince1970: 1_234_567_890),
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: mockRates
        )

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
        
        await testStore.send(.fetchCurrencies)
        await testStore.receive(.receiveCurrency(.success(currencyExchange))) {
            $0.model = currencyExchange
            $0.model.lastFetchedTime = Date(timeIntervalSince1970: 1_234_567_890)
            $0.model.oldSelectedCurrency = "USD"
            $0.items = mockIdntifiedArray(mockRates)
        }
        await testClock.advance(by: .seconds(1))

    }
    
    func test_fetchCurrencies_fromApiAfter60Minutes() async {
        // Create a starting date
        let startingDate = Date(timeIntervalSince1970: 1_234_567_890) // Use the current date and time as an example

        // Add 60 minutes to the starting date
        let calendar = Calendar.current
        let endingDate = calendar.date(byAdding: .minute, value: 60, to: startingDate)!

        let currencyExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            timestamp: 0,
            lastFetchedTime: startingDate,
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: mockRates
        )

        let testClock = TestClock()

        let testStore = TestStore(
            initialState: CurrencyExchangeFeature.State(
                model: currencyExchange)
        ) {
            CurrencyExchangeFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date.now = endingDate
            $0.continuousClock = testClock
            $0.currencyApiClient = .default()
            $0.currencyApiClient.getCurrencyExchangeRates = { _ in currencyExchange }
            $0.dataManager = .mock(
                initialData: try! JSONEncoder().encode(currencyExchange)
              )
            $0.calendar = .current
        }

        
        
        await testStore.send(.fetchCurrencies)
        let expected = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: "USD",
            timestamp: 0,
            lastFetchedTime: startingDate,
            currencyValue: 1.0,
            currencyExchangeValue: 1.0,
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: [
              "AED": 3.672075,
              "AFN": 87.999996,
              "ALL": 102.3,
              "AMD": 386.31,
              "ANG": 1.801776,
              "USD": 1.0
            ]
          )
        await testStore.receive(.receiveCurrency(.success(expected))) {
            $0.model = currencyExchange
            $0.model.lastFetchedTime = endingDate
            $0.model.base = "USD"
            $0.model.oldSelectedCurrency = "USD"
            $0.items = mockIdntifiedArray(mockRates)
        }
        await testClock.advance(by: .seconds(1))

    }
    
    func test_fetchCurrencies_fromApiAfter60Minutes_retrieveToOldCurrencyBase() async {
        // Create a starting date
        let startingDate = Date(timeIntervalSince1970: 1_234_567_890) // Use the current date and time as an example

        // Add 60 minutes to the starting date
        let calendar = Calendar.current
        let endingDate = calendar.date(byAdding: .minute, value: 60, to: startingDate)!

        let currencyExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            timestamp: 0,
            lastFetchedTime: startingDate,
            selectedCurrency: "AED",
            oldSelectedCurrency: "AED",
            rates: mockRatesBaseAED
        )

        let testClock = TestClock()

        let testStore = TestStore(
            initialState: CurrencyExchangeFeature.State(
                model: currencyExchange)
        ) {
            CurrencyExchangeFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date.now = endingDate
            $0.continuousClock = testClock
            $0.currencyApiClient = .default()
            $0.currencyApiClient.getCurrencyExchangeRates = { _ in currencyExchange }
            $0.dataManager = .mock(
                initialData: try! JSONEncoder().encode(currencyExchange)
              )
            $0.calendar = .current
        }

        
        
        await testStore.send(.fetchCurrencies) {
            $0.model.selectedCurrency = "USD"
        }
        let expected = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: "AED",
            timestamp: 0,
            lastFetchedTime: startingDate,
            currencyValue: 1.0,
            currencyExchangeValue: 1.0,
            selectedCurrency: "AED",
            oldSelectedCurrency: "AED",
            rates: [
              "AED": 1.0,
              "AFN": 23.964651048793936,
              "ALL": 27.85890811053696,
              "AMD": 105.202099630318,
              "ANG": 0.49066971671330245,
              "USD": 0.27232559247836713
            ]
          )
        await testStore.receive(.receiveCurrency(.success(expected))) {
            $0.model = expected
            $0.model.lastFetchedTime = endingDate
            $0.model.base = "AED"
            $0.model.oldSelectedCurrency = "AED"
            $0.items = mockIdntifiedArray(mockRatesBaseAED)
        }
        await testClock.advance(by: .seconds(1))

    }

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
            $0.items = mockIdntifiedArray(mockRates)
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
            $0.items = mockIdntifiedArray(mockRates)
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
    
    
    func test_binding_currencyValue() async {
        let currencyExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            timestamp: 0,
            lastFetchedTime: Date(timeIntervalSince1970: 1_234_567_890),
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: mockRates
        )

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
        
        
        await testStore.send(.binding(.set(\.$model.currencyValue, 2))) {
            $0.model.currencyValue = 2.0
        }
        let expectedRates = [
          "AED": 3.672075,
          "AFN": 87.999996,
          "ALL": 102.3,
          "AMD": 386.31,
          "ANG": 1.801776,
          "USD": 1.0
        ]

        let expected = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: nil,
            timestamp: 0,
            lastFetchedTime: Date(timeIntervalSince1970: 1_234_567_890),
            currencyValue: 2.0,
            currencyExchangeValue: 1.0,
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: expectedRates
          )

        await testStore.receive(.receiveCurrency(.success(expected))) {
            $0.model = expected
            $0.model.lastFetchedTime = Date(timeIntervalSince1970: 1_234_567_890)
            $0.model.oldSelectedCurrency = "USD"
            $0.items = mockIdntifiedArray(mockRates, value: 2)
        }
        await testClock.advance(by: .seconds(1))

    }
    

    func test_binding_selectedCurrency_differentCountry() async throws {
        let currencyExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: "USD",
            timestamp: 0,
            lastFetchedTime: Date(timeIntervalSince1970: 1_234_567_890),
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: mockRates
        )
        
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
        
        await testStore.send(.binding(.set(\.$model.selectedCurrency, "AED"))) {
            $0.model.selectedCurrency = "AED"
        }
        await testStore.receive(.currencyBaseChanged("AED"))
        let expectedExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: "AED",
            timestamp: 0,
            lastFetchedTime: Date(timeIntervalSince1970: 1_234_567_890),
            selectedCurrency: "AED",
            oldSelectedCurrency: "USD",
            rates: mockRatesBaseAED
        )

        await testStore.receive(.receiveCurrency(.success(expectedExchange))) {
            $0.model = expectedExchange
            $0.model.lastFetchedTime = Date(timeIntervalSince1970: 1_234_567_890)
            $0.model.oldSelectedCurrency = "AED"
            $0.items = mockIdntifiedArray(mockRatesBaseAED)
        }
        await testClock.advance(by: .seconds(1))

    }
    
    func test_loadDataFailed() {
        let currencyExchange = CurrencyExchange(
            disclaimer: "disclaimer",
            license: "license",
            base: "USD",
            timestamp: 0,
            lastFetchedTime: nil,
            selectedCurrency: "USD",
            oldSelectedCurrency: "USD",
            rates: mockRates
        )

        let testStore = TestStore(
            initialState: CurrencyExchangeFeature.State(
                model: currencyExchange)
        ) {
            CurrencyExchangeFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
            $0.continuousClock = ImmediateClock()
            $0.dataManager = .mock(
                initialData: Data("!@#$ BAD DATA %^&*()".utf8)
              )
            $0.calendar = .current
        }

        XCTAssertEqual(testStore.state.model.lastFetchedTime, nil)
    }
    
    func test_saveDataFailed() async {
        let currencyExchange = CurrencyExchange.mock
        let testClock = TestClock()
        struct RefreshFailure: Error {}
        let failure = RefreshFailure()

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
            $0.dataManager.save = { (_,_) in
                throw failure
            }
            $0.calendar = .current
        }
        
        await testStore.send(.refresh)
        await testStore.receive(.fetchCurrencies)
        await testStore.receive(.receiveCurrency(.success(currencyExchange))) {
            $0.model = currencyExchange
            $0.model.lastFetchedTime = Date(timeIntervalSince1970: 1_234_567_890)
            $0.items = mockIdntifiedArray(mockRates)
        }
        await testClock.advance(by: .seconds(1))
        
    }
    
}






