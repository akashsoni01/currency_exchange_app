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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
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
    
//    func test_receiveCurrency_success() async throws {
//        let currencyExchange = CurrencyExchange.mock
//        let testStore = TestStore(
//            initialState: CurrencyExchangeFeature.State(
//                model: currencyExchange)
//        ) {
//            CurrencyExchangeFeature()
//        } withDependencies: {
//            $0.continuousClock = ImmediateClock()
//            $0.currencyApiClient.getCurrencyExchangeRates = { _ in
//                currencyExchange
//            }
//            $0.dataManager = .mock(
//                initialData: try! JSONEncoder().encode(currencyExchange)
//            )
//        }
//        store.exhaustivity = .off(showSkippedAssertions: true)
//        
//        let savedData = LockIsolated(Data?.none)
//        testStore.dependencies.dataManager.save = { data, _ in savedData.setValue(data) }
//
//        await testStore.send(.receiveCurrency(.success(currencyExchange))) {
//            $0.model = currencyExchange
//        }
//        await testStore.receive(., timeout: <#T##Duration#>)
//    }
    
//    func test_receiveCurrency_fail() async throws {
//        let currencyExchange = CurrencyExchange.mock
//        let testStore = TestStore(
//            initialState: CurrencyExchangeFeature.State(
//                model: currencyExchange)
//        ) {
//            CurrencyExchangeFeature()
//        } withDependencies: {
//            $0.continuousClock = ImmediateClock()
//            $0.currencyApiClient = .default()
//            $0.dataManager = .mock(
//                initialData: Data("!@#$ BAD DATA %^&*()".utf8)
//              )
//
//        }
//    }

}







