//
//  ProductPreviewView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 08.09.2025.
//

import SwiftUI

struct ProductCellView: View {
    let product: Product
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            AsyncImage(
                url: URL(string: product.thumbnail ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 75, height: 75)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4){
                Text(product.title ?? "Nah")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Price: $" + (product.price?.description ?? "0"))
                Text("Rating: " + (product.rating?.description ?? "0"))
                Text("Category: " + (product.category ?? "nah"))
                Text("Brand: " +  (product.brand?.description ?? "nah"))
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
    }
}
