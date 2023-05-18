//
//  CurrencyExchangeView.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import ComposableArchitecture
import SwiftUI

struct ItemModel: Codable, Equatable, Identifiable {
    let id: UUID
    var title: String
    var rate: Double
    init(
        id: UUID? = nil,
        title: String,
        rate: Double
    ) {
        @Dependency(\.uuid) var uuid
        self.id = id ?? uuid()
        self.title = title
        self.rate = rate
        
    }
}

struct CurrencyExchangeFeature: Reducer {
    struct State: Equatable {
        let id: UUID
        var title: String = "Choose Currency"
        var currencyValue = 1.0
        var items: IdentifiedArrayOf<ItemModel> = []
        init(
            id: UUID? = nil
        ) {
            @Dependency(\.uuid) var uuid
            self.id = id ?? uuid()
        }

    }
    
    enum Action {
        case viewWillAppear
        case receiveCurrency(TaskResult<CurrencyExchange>)
        case receiveCurrencyLocally(TaskResult<CurrencyExchange>)
        case changeBase(String)
    }
    
    @Dependency(\.currencyApiClient) var currencyApiClient
    @Dependency(\.dataManager) var dataManager
    
    private enum CancelID {
        case api
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .viewWillAppear:
                // call api and set data
                return .run { send in
                    do {
                        let data = try await self.dataManager.load(.currencyLocalStorageUrl)
                        await send(.receiveCurrencyLocally(
                            TaskResult {
                                (try JSONDecoder().decode(CurrencyExchange.self, from: data))
                            }
                        ))
                    } catch {
                        await send(
                            .receiveCurrency(
                                TaskResult { try await self.currencyApiClient.getCurrencyExchangeRates("USD")
                                }
                            )
                        )
                    }


                }.cancellable(id: CancelID.api)

            case let .receiveCurrency(response):
                switch response {
                case let .success(model):
                    state.title = model.base ?? ""
                    var array: IdentifiedArrayOf<ItemModel> = []
                    model.rates?.forEach { (key, value) in
                        let total = value*state.currencyValue
                        array.append(ItemModel(title: key, rate: total))
                    }
                    state.items = array
                    print(".receivedPost(response): success = \(model)")
                    return .run { send in
                        try? await self.dataManager.save(
                            JSONEncoder().encode(model),
                            .currencyLocalStorageUrl
                        )

                    }
                    
                case let .failure(error):
                    print(error.localizedDescription)
                    return .none
                    
                }

            case let .receiveCurrencyLocally(response):
                print(".receivedPost(response): success = \(response)")
                guard case let .success(model) = response, let lastFetchedTime = model.lastFetchedTime else { return .none }
                
                return .run { send in
                    let calendar = Calendar.current
                    let startDate = lastFetchedTime // if you want to call according to api last fetched
                    let endDate = Date()
                    let components = calendar.dateComponents([.minute], from: startDate, to: endDate)
                    let distenceInMin = components.minute ?? 0
                    if distenceInMin > 60 {
                        // if api didn't call from last __ minutes then call api again
                        await send(
                            .receiveCurrency(
                                TaskResult { try await self.currencyApiClient.getCurrencyExchangeRates("USD")
                                }
                            )
                        )
                    } else {
                        await send(
                            .receiveCurrency(response)
                        )
                    }
                }
            }
        }
    }
}

struct CurrencyExchangeView: View {
    private let store: StoreOf<CurrencyExchangeFeature>
    
    init(store: StoreOf<CurrencyExchangeFeature>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        let title: String
        var items: IdentifiedArrayOf<ItemModel>

        init(state: CurrencyExchangeFeature.State) {
            self.title = state.title
            self.items = state.items
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { (viewStore: ViewStore<ViewState, CurrencyExchangeFeature.Action>) in
            List {
                Text(viewStore.title)
            }
            .onAppear{
                viewStore.send(.viewWillAppear)
            }
        }
    }
}

struct CurrencyExchangeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CurrencyExchangeView(store:
                                    Store(initialState: CurrencyExchangeFeature.State(), reducer: CurrencyExchangeFeature())
            )
        }
    }
}


//Todo
/*
 1. ui populate data
 2. take different input
 3. create a list from open search currency to create it as base
 4. paid currency
 5. UTs 
 */
