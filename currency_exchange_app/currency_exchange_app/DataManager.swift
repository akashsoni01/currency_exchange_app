//
//  DataManager.swift
//  currency_exchange_app
//
//  Created by Akash soni on 18/05/23.
//

import Dependencies
import Foundation

public struct DataManager: Sendable {
    public var load: @Sendable (URL) async throws -> Data
    public var save: @Sendable (Data, URL) async throws -> Void
}

extension DataManager: DependencyKey {
    public static let liveValue = DataManager(
        load: { url in try Data(contentsOf: url) },
        save: { data, url in try data.write(to: url) }
    )
    
    public static let testValue = DataManager(
        load: unimplemented("DataManager.load"),
        save: unimplemented("DataManager.save")
    )
}

extension DependencyValues {
    public var dataManager: DataManager {
        get { self[DataManager.self] }
        set { self[DataManager.self] = newValue }
    }
}

extension DataManager {
    public static func mock(initialData: Data? = nil) -> DataManager {
        let data = LockIsolated(initialData)
        return DataManager(
            load: { _ in
                guard let data = data.value
                else {
                    struct FileNotFound: Error {}
                    throw FileNotFound()
                }
                return data
            },
            save: { newData, _ in data.setValue(newData) }
        )
    }
    
    public static let failToWrite = DataManager(
        load: { url in Data() },
        save: { data, url in
            struct SaveError: Error {}
            throw SaveError()
        }
    )
    
    public static let failToLoad = DataManager(
        load: { _ in
            struct LoadError: Error {}
            throw LoadError()
        },
        save: { newData, url in }
    )
}

extension URL {
    public static let currencyLocalStorageUrl = Self.documentsDirectory.appending(component: "currencies.json")
}
