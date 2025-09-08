//
//  ProductsManager.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 08.09.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

final class ProductsManager {
    
    static let shared = ProductsManager()
    private init() {}
    
    private let productsCollection: CollectionReference = Firestore.firestore().collection("products")
    
    @discardableResult
    private func productDocument(productID: String) async throws -> DocumentReference{
        productsCollection.document(productID)
    }
    
    func uploadProduct(product: Product) async throws{
        try await productDocument(productID: product.id.description).setData(from: product, merge: false)
    }
    
    func getProduct(productID: String) async throws -> Product {
        try await productDocument(productID: productID).getDocument(as: Product.self)
    }
    
    func getAllProducts() async throws -> [Product]{
        try await productsCollection.getDocuments2(as: Product.self)
    }
}

extension Query {
    func getDocuments2<T: Codable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        var products: [T] = []
        for document in snapshot.documents {
            let product = try document.data(as: T.self)
            products.append(product)
        }
        return products
        
    }
}
