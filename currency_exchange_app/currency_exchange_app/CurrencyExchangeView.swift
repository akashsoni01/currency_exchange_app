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
        var title: String = "Hello world"
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
                        await send(.receiveCurrency(
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
                        array.append(ItemModel(title: key, rate: value))
                    }
                    state.items = array
                    print(".receivedPost(response): success = \(model)")
                    return .run { send in
                        let calendar = Calendar.current
                        
                         let startDate = Date(timeIntervalSince1970: TimeInterval(model.timestamp)) // if you want to call according to api last fetched
                        // let startDate = model.lastStoredLocally // if you want to fetch according to last saved time

                        let endDate = Date()

                        let components = calendar.dateComponents([.minute], from: startDate, to: endDate)
                        let distenceInMin = components.minute ?? 0
                        if distenceInMin > 60 {
                            // if api not getting called from last __ minutes then call api again
                            await send(
                                .receiveCurrency(
                                    TaskResult { try await self.currencyApiClient.getCurrencyExchangeRates("USD")
                                    }
                                )
                            )

                        }
                        
                        
                        try? await self.dataManager.save(
                            JSONEncoder().encode(model),
                            .currencyLocalStorageUrl
                        )

                    }
                    
                case let .failure(error):
                    print(error.localizedDescription)
                    return .none
                    
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
