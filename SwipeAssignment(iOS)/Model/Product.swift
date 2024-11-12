//
//  Product.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 10/11/24.
//

import Foundation


struct Product: Hashable, Codable, Identifiable {
    let productName: String
    let productType: String
    let price: Double
    let tax: Double
    let image: String
    var isFavorite: Bool
    
    // id for better list management
    var id: String { productName + productType }
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productType = "product_type"
        case price = "price"
        case tax = "tax"
        case image = "image"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productName = try container.decode(String.self, forKey: .productName)
        productType = try container.decode(String.self, forKey: .productType)
        price = try container.decode(Double.self, forKey: .price)
        tax = try container.decode(Double.self, forKey: .tax)
        image = try container.decode(String.self, forKey: .image)
        isFavorite = false 
    }
    
    init(productName: String, productType: String, price: Double, tax: Double, image: String, isFavorite: Bool) {
        self.productName = productName
        self.productType = productType
        self.price = price
        self.tax = tax
        self.image = image
        self.isFavorite = isFavorite
    }
}
