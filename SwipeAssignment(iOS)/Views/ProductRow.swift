//
//  ProductRow.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 10/11/24.
//

import SwiftUI

struct ProductRow: View {
    // Core properties
    let product: Product
    let onFavorite: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var totalPrice: Double {
        product.price * (1 + product.tax/100)
    }
    
    // MARK: - View Layout
    var body: some View {
            HStack(spacing: 12) {
                // Product Image
                AsyncImage(url: URL(string: product.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.1))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                        )
                }
                
                // Product Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.productName)
                        .font(.system(size: 15, weight: .medium))
                        .lineLimit(1)
                    
                    Text(product.productType)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.08))
                        .clipShape(Capsule())
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("₹\(product.price.formatted())")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text("+\(product.tax, specifier: "%.1f")%")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onFavorite) {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(product.isFavorite ? .red : .gray)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(BorderlessButtonStyle())
                .scaleEffect(product.isFavorite ? 1.1 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: product.isFavorite)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color(.tertiarySystemBackground) : .white)
                    .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
            )
        }
    }


#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        ProductRow(
            product: Product(
                productName: "iPhone 16 Pro",
                productType: "Phone",
                price: 89999,
                tax: 12,
                image: "",
                isFavorite: false
            ),
            onFavorite: {}
        )
    }
}
