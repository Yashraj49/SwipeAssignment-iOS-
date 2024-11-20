//
//  Manager.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 10/11/24.
//

import SwiftUI
import Alamofire

class Manager: ObservableObject {  // MARK: - Published Properties  // Observable properties for UI updates
   
    @Published var products: [Product] = []
    @Published var alertDescription: String = ""
    @Published var showAlert = false
    @Published var error: Error?
    @Published var isLoading = false
    @Published var productTimestamps: [String: Date] = [:]
    
    @Published private(set) var offlineProducts: [Product] = []
    private let networkMonitor = NetworkMonitor()
    
    private let favoritesKey = "FavoriteProducts"
    
    init() {
        products = []
        alertDescription = ""
        showAlert = false
        loadFavorites()
        loadOfflineProducts()
        syncOfflineProductsIfNeeded()
    }
    
    // load favorites from UserDefaults
    private func loadFavorites() {
        if let favoriteIds = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            for (index, _) in products.enumerated() {
                products[index].isFavorite = favoriteIds.contains(products[index].id)
            }
            sortProducts()
        }
    }
    
    //save favorites to UserDefaults
    private func saveFavorites() {
        let favoriteIds = products.filter { $0.isFavorite }.map { $0.id }
        UserDefaults.standard.set(favoriteIds, forKey: favoritesKey)
    }
    
    // Toggle favorite status
    func toggleFavorite(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].isFavorite.toggle()
            sortProducts()
            saveFavorites()
        }
    }
    
    // sort products with favorites at the top
    private func sortProducts() {
        products.sort { (product1, product2) -> Bool in
            if product1.isFavorite == product2.isFavorite {
                // If both are favorite or both are not, sort by timestamp
                let timestamp1 = productTimestamps[product1.id] ?? Date.distantPast
                let timestamp2 = productTimestamps[product2.id] ?? Date.distantPast
                return timestamp1 > timestamp2
            }
            return product1.isFavorite && !product2.isFavorite
        }
    }
    
    private func loadOfflineProducts() {
        offlineProducts = CoreDataManager.shared.fetchOfflineProducts()
    }
    
    private func syncOfflineProductsIfNeeded() {
        guard networkMonitor.isConnected, !offlineProducts.isEmpty else { return }
        
        Task {
            for product in offlineProducts {
                await postMethod(product: product)
                CoreDataManager.shared.deleteOfflineProduct(product)
            }
            await MainActor.run {
                offlineProducts = []
            }
        }
    }
    
    func addProduct(_ product: Product) async {
        if networkMonitor.isConnected {
            await postMethod(product: product)
        } else {
            CoreDataManager.shared.saveOfflineProduct(product)
            await MainActor.run {
                offlineProducts.append(product)
                showAlert = true
                alertDescription = "Product saved offline. Will sync when connected."
            }
        }
    }
   
    func getProducts() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        // modified getProducts to handle favorites
        let urlString = "https://app.getswipe.in/api/public/get"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.error = NetworkHandling.invalidURL
                self.isLoading = false
            }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.error = NetworkHandling.invalidResponse
                    self.isLoading = false
                }
                return
            }
            
            let decoder = JSONDecoder()
            guard let result = try? decoder.decode([Product].self, from: data) else {
                DispatchQueue.main.async {
                    self.error = NetworkHandling.invalidData
                    self.isLoading = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.products = result
                self.loadFavorites()
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = NetworkHandling.unknownError(error)
                self.isLoading = false
            }
        }
    }
    
    /// Posts new product to the API using Alamofire
    func postMethod(product: Product) async {
        
        let parameters: [String: String] = [
            "product_name": product.productName,
            "product_type": product.productType,
            "price": String(product.price),
            "tax": String(product.tax)
        ]
        
        let urlString = "https://app.getswipe.in/api/public/add"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        ]
        
       
        await withCheckedContinuation { continuation in
            AF.request(url,      // created a continuation to handle the async response
                      method: .post,
                      parameters: parameters, //used type-safe parameters
                      encoding: URLEncoding.httpBody,
                      headers: headers)
                .responseJSON { [weak self] response in
                    guard let self = self else { return }
                    
                    switch response.result {
                    case .success:
                        Task { @MainActor in
                            self.products.insert(product, at: 0)
                            self.productTimestamps[product.id] = Date()
                            self.sortProducts()
                            self.showAlert = true
                            self.alertDescription = "successfully added new product"
                        }
                    case .failure:
                        Task { @MainActor in
                            self.showAlert = true
                            self.alertDescription = "Error in adding this product"
                        }
                    }
                    continuation.resume()
                }
        }
    }
}
