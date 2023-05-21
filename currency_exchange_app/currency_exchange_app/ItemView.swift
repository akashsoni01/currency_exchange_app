//
//  ItemView.swift
//  currency_exchange_app
//
//  Created by Akash soni on 20/05/23.
//

import SwiftUI

struct ItemView: View {
    @State private var isAnimating = false
    private let item: ItemModel
    
    init(item: ItemModel) {
        self.item = item
    }
    
    var body: some View {
        Rectangle()
            .cornerRadius(8)
            .foregroundColor(.blue)
            .overlay(
                HStack {
                    Text(item.title)
                        .font(.body)
                        .foregroundColor(.white)
                    
                    Text(String(format: "%.4f", item.rate))
                        .font(.body)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            )
            .shadow(color: .gray, radius: 4, x: 0, y: 2)
    }
}

