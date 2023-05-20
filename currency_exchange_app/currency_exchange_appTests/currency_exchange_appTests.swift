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

/*
 func test_test_viewWillAppear_loadDataFailed() async throws {
     let currencyExchange = CurrencyExchange.mock
     let testStore = TestStore(
         initialState: CurrencyExchangeFeature.State(
             model: currencyExchange)
     ) {
         CurrencyExchangeFeature()
     } withDependencies: {
         $0.continuousClock = ImmediateClock()
         $0.currencyApiClient = .default()
         $0.dataManager = .mock(
             initialData: Data("!@#$ BAD DATA %^&*()".utf8)
           )
     }
 }
 
 func test_test_viewWillAppear_dataNotFound() async throws {
     let currencyExchange = CurrencyExchange.mock
     let testStore = TestStore(
         initialState: CurrencyExchangeFeature.State(
             model: currencyExchange)
     ) {
         CurrencyExchangeFeature()
     } withDependencies: {
         $0.continuousClock = ImmediateClock()
         $0.currencyApiClient = .default()
         $0.dataManager.load = { _ in
             struct FileNotFound: Error {}
             throw FileNotFound()
           }
     }
 }
 
 func test_viewWillAppear() async throws {
     let currencyExchange = CurrencyExchange.mock
     let testStore = TestStore(
         initialState: CurrencyExchangeFeature.State(
             model: currencyExchange)
     ) {
         CurrencyExchangeFeature()
     } withDependencies: {
         $0.continuousClock = ImmediateClock()
         $0.currencyApiClient = .default()
         $0.dataManager = .mock(
             initialData: try! JSONEncoder().encode(currencyExchange)
         )

     }
     let savedData = LockIsolated(Data?.none)
     testStore.dependencies.dataManager.save = { data, _ in savedData.setValue(data) }

     await testStore.send(.viewWillAppear)
     await testStore.receive(.receiveCurrencyLocally(.success(currencyExchange)), timeout: 5)


 }
 */
    
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
            $0.currencyApiClient = .default()
            $0.currencyApiClient.getCurrencyExchangeRates = { _ in currencyExchange }
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
            $0.continuousClock = ImmediateClock()
            $0.currencyApiClient = .default()
            $0.currencyApiClient.getCurrencyExchangeRates = { string in throw failure }
            $0.dataManager = .mock(
                initialData: try! JSONEncoder().encode(currencyExchange)
              )
        }
        await testStore.send(.receiveCurrency(.failure(failure)))
    }

}






