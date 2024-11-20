//
//  CoreDataManager.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 19/11/24.
//


import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ProductModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    func saveOfflineProduct(_ product: Product) {
        let context = persistentContainer.viewContext
        let offlineProduct = OfflineProduct(context: context)
        offlineProduct.productName = product.productName
        offlineProduct.productType = product.productType
        offlineProduct.price = product.price
        offlineProduct.tax = product.tax
        offlineProduct.image = product.image
        offlineProduct.isFavorite = product.isFavorite
        offlineProduct.timestamp = Date()
        
        do {
            try context.save()
        } catch {
            print("Failed to save offline product: \(error)")
        }
    }
    
    func fetchOfflineProducts() -> [Product] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<OfflineProduct> = OfflineProduct.fetchRequest()
        
        do {
            let offlineProducts = try context.fetch(request)
            return offlineProducts.map { offline in
                Product(
                    productName: offline.productName ?? "",
                    productType: offline.productType ?? "",
                    price: offline.price,
                    tax: offline.tax,
                    image: offline.image ?? "",
                    isFavorite: offline.isFavorite
                )
            }
        } catch {
            print("Failed to fetch offline products: \(error)")
            return []
        }
    }
    
    func deleteOfflineProduct(_ product: Product) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<OfflineProduct> = OfflineProduct.fetchRequest()
        request.predicate = NSPredicate(format: "productName == %@ AND productType == %@", product.productName, product.productType)
        
        do {
            let matches = try context.fetch(request)
            matches.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Failed to delete offline product: \(error)")
        }
    }
}
