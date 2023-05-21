//
//  CurrencyExchangeFeature.swift
//  currency_exchange_app
//
//  Created by Akash soni on 20/05/23.
//

import ComposableArchitecture
import SwiftUI

struct CurrencyExchangeFeature: Reducer {
    struct State: Equatable {
        var items: IdentifiedArrayOf<ItemModel> = []
        @BindingState var model: CurrencyExchange

        init(
            model: CurrencyExchange
        ) {
            do {
                @Dependency(\.dataManager.load) var load
                self.model = try JSONDecoder().decode(CurrencyExchange.self, from: load(.currencyLocalStorageUrl))
            } catch {
                self.model = model
            }
        }
    }
    
    enum Action: BindableAction, Equatable {
        case task
        case fetchCurrencies
        case receiveCurrency(TaskResult<CurrencyExchange>)
        case currencyBaseChanged(String)
        case binding(BindingAction<State>)
        case refresh
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.currencyApiClient) var currencyApiClient
    @Dependency(\.dataManager.save) var saveData
    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar

    private enum CancelID {
        case saveDebounce
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .run { send in
                    await send(.fetchCurrencies)
                }
                
            case let .receiveCurrency(response):
                switch response {
                case let .success(model):
                    state.model = model
                    state.model.lastFetchedTime = self.now
                    state.model.oldSelectedCurrency = state.model.selectedCurrency
                    if let keys = model.rates?.keys.sorted() {
                        var array = IdentifiedArrayOf<ItemModel>()
                        keys.forEach { (key) in
                            if let value = model.rates?[key] {
                                let total = value * state.model.currencyValue
                                array.append(ItemModel(title: key, rate: total))
                            }
                        }
                        state.items = array
                    }
                    
                    return .run { [model = state.model] _ in
                      try await withTaskCancellation(id: CancelID.saveDebounce, cancelInFlight: true) {
                        try await self.clock.sleep(for: .seconds(1))
                          try? await self.saveData(
                              JSONEncoder().encode(model),
                              .currencyLocalStorageUrl
                          )
                      }
                    } catch: { _, _ in
                    }

                case .failure:
                    print("Something went wrong")
                    return .none
                    
                }

            case .fetchCurrencies:
                if let lastFetchedTime = state.model.lastFetchedTime {
                        let startDate = lastFetchedTime // if you want to call according to api last fetched
                        let endDate = self.now
                        let components = self.calendar.dateComponents([.minute], from: startDate, to: endDate)
                        let distenceInMin = components.minute ?? 0
                        if distenceInMin <= 60 {
                            return .run { [model = state.model] send in
                                await send(.receiveCurrency(
                                    TaskResult { model }
                                ))
                            }
                        } else {
                            // if api didn't call from last 60 minutes then call api again with USD and change base currency
                            state.model.selectedCurrency = "USD"
                            return .run { [oldKey = state.model.oldSelectedCurrency] send in
                                await send(
                                    .receiveCurrency(
                                        TaskResult {
                                            try await self.currencyApiClient.getCurrencyExchangeRates("USD")
                                        }
                                    )
                                )
                                
                                await send(
                                    .currencyBaseChanged(oldKey)
                                )
                            }
                        }
                    } else {
                        state.model.selectedCurrency = "USD"
                        return .run { send in
                            await send(
                                .receiveCurrency(
                                    TaskResult { try await self.currencyApiClient.getCurrencyExchangeRates("USD")
                                    }
                                )
                            )
                        }
                    }
                
            case .binding(\.$model.currencyValue):
                return .run { [model = state.model] send in
                    await send(
                        .receiveCurrency(
                            TaskResult { model }
                        )
                    )
                }
                
            case .binding(\.$model.selectedCurrency):
                return .run { [selectedCurrency = state.model.selectedCurrency] send in
                    await send(.currencyBaseChanged(selectedCurrency))
                }
                

            case .binding(_):
                return .none
                
                
            case let .currencyBaseChanged(newKey):
                if newKey == state.model.oldSelectedCurrency {
                    return .none
                } else {
                    let model = changeOldBaseWithNew(model: state.model, oldKey: state.model.oldSelectedCurrency, newKey: newKey)
                    return .run { send in
                        await send(
                            .receiveCurrency(
                                TaskResult { model }
                            )
                        )
                    }

                }
                
            case .refresh:
                return .run { [selectedCurrency = state.model.selectedCurrency] send in
                    await send(
                        .receiveCurrency(
                            TaskResult { try await self.currencyApiClient.getCurrencyExchangeRates(selectedCurrency)
                            }
                        )
                    )
                }

            }
            
            @Sendable func changeOldBaseWithNew(model: CurrencyExchange, oldKey: String, newKey: String) -> CurrencyExchange {
                var model = model
                if let oldRate = model.rates?[oldKey],
                   let newRate = model.rates?[newKey] {
                    model.rates?[oldKey] = oldRate / newRate
                    model.rates?[newKey] = 1

                    for key in model.sortedKeys {
                           if let other = model.rates?[key] {
                            if key == newKey || key == oldKey {
                                // do nothing
                            } else {
                                model.rates?[key] = other / newRate
                            }
                        }
                    }
                }
                model.selectedCurrency = newKey
                model.base = newKey

                return model
            }
        }
    }
}
