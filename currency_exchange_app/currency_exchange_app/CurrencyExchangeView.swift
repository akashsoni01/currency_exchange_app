//
//  CurrencyExchangeView.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import ComposableArchitecture
import SwiftUI

struct ItemModel: Codable, Equatable, Identifiable, Hashable {
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
        @BindingState var currencyValue = 1.0
        @BindingState var currencyExchangeValue = 1.0
//        @BindingState var selectedKey: ItemModel? = nil
        var selectedKey: String = "USD"
        var items: IdentifiedArrayOf<ItemModel> = []
        var model: CurrencyExchange = CurrencyExchange(disclaimer: nil, license: nil, base: nil, timestamp: 0)

        init(
            id: UUID? = nil,
            model: CurrencyExchange = CurrencyExchange(disclaimer: nil, license: nil, base: nil, timestamp: 0)
        ) {
            @Dependency(\.uuid) var uuid
            self.id = id ?? uuid()
            self.model = model
        }

    }
    
    enum Action: BindableAction, Equatable {
        case viewWillAppear
        case receiveCurrency(TaskResult<CurrencyExchange>)
        case receiveCurrencyLocally(TaskResult<CurrencyExchange>)
        case currencyChanged(String)
        case binding(BindingAction<State>)

    }
    
    @Dependency(\.currencyApiClient) var currencyApiClient
    @Dependency(\.dataManager) var dataManager
    
    private enum CancelID {
        case api
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
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
                    state.model = model
                    var array = [ItemModel]()
                    model.rates?.forEach { (key, value) in
                        let total = value*state.currencyExchangeValue
                        array.append(ItemModel(title: key, rate: total))
                    }
                    array.sort{ $0.title < $1.title }
                    state.items = IdentifiedArrayOf(uniqueElements: array)

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
                                
            case .binding(_):
                return .none
                
            case let .currencyChanged(newKey):
                //                    Exchanged one (USD) = Old rate / New rate
                //                    All other = other / new rate
                defer {
                    // replace old base with new
                    state.selectedKey = newKey
                }
                let model = changeOldBaseWithNew(model: state.model, oldKey: state.selectedKey, newKey: newKey)
                return .run { send in
                    await send(
                        .receiveCurrency(
                            TaskResult {
                                model
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

                return model
            }
        }
    }
}

struct CurrencyExchangeView: View {
    private let store: StoreOf<CurrencyExchangeFeature>
    
    init(store: StoreOf<CurrencyExchangeFeature>) {
        self.store = store
    }
        
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                HStack{
                    TextField("Enter a value", value: viewStore.binding(\.$currencyExchangeValue), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .padding()

                    CurrencyPickerView(selectedKey: viewStore.binding(get: \.selectedKey, send: CurrencyExchangeFeature.Action.currencyChanged), keyValues: viewStore.model.rates ?? [:])
                }
                List {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80))
                        ], spacing: 16) {
                            ForEach(viewStore.items, id: \.id) { item in
                                HStack {
                                    Text(String(format: "\(item.title) %.4f", item.rate))
                                        .frame(width: 80)
                                        .frame(height: 80)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
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
