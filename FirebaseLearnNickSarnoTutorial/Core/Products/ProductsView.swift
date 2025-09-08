//
//  ProductsView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 08.09.2025.
//
import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {
    /*
     func downloadProductsAndUploadToFirebase() {
     guard let url = URL(string: "https://dummyjson.com/products") else {return}
     
     Task {
     do {
     let (data, response) = try await URLSession.shared.data(from: url)
     let products = try JSONDecoder().decode(ProductArray.self, from: data)
     let productArray = products.products
     
     for product in productArray {
     try? await ProductsManager.shared.uploadProduct(product: product)
     }
     
     print("Success")
     print(products.products.count)
     } catch {
     print(error)
     }
     }
     }
     */
    
    @Published private(set) var products: [Product] = []
    
    func getAllProducts() async throws {
        self.products = try await ProductsManager.shared.getAllProducts()
    }
}

struct ProductsView: View {
    @StateObject private var productsVM: ProductsViewModel = .init()
    var body: some View {
        List{
            ForEach(productsVM.products) {product in
                ProductCellView(product: product)
            }
        }
        .task {
            try? await productsVM.getAllProducts()
        }
    }
}

#Preview {
    NavigationStack{
        ProductsView()
    }
}
