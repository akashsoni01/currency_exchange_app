//
//  CurrencyExchangeView.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import ComposableArchitecture
import SwiftUI

struct CurrencyExchangeFeature: Reducer {
    struct State: Equatable {
        let id: UUID
        var model: CurrencyExchange?
        var title: String = "Hello world"
        
        init(
            id: UUID? = nil
        ) {
            @Dependency(\.uuid) var uuid
            self.id = id ?? uuid()
        }

    }
    
    enum Action: Equatable {
        case viewWillAppear
        case receiveCurrency(TaskResult<CurrencyExchange>)
    }
    
    @Dependency(\.currencyApiClient) var currencyApiClient
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .viewWillAppear:
                // call api and set data
                return .run { send in
                    await send(
                        .receiveCurrency(
                            TaskResult { try await self.currencyApiClient.getCurrencyExchangeRates("USD")
                            }
                        )
                    )
                }
                
            case let .receiveCurrency(response):
                switch response {
                case let .success(model):
                    state.title = model.base ?? ""
                    print(".receivedPost(response): success = \(model)")
                    return .none
                    
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
        
        init(state: CurrencyExchangeFeature.State) {
            self.title = state.title
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            List {
                Text(viewStore.title)
            }
            .onAppear{
                viewStore.send(.viewWillAppear)
            }
            .toolbar {
            }
            Text("Select an item")
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
