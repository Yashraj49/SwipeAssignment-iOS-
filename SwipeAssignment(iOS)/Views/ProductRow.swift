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
        HStack(spacing: 16) {
            // Product Image
            AsyncImage(url: URL(string: product.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 85, height: 85)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.1))
                    .frame(width: 85, height: 85)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    )
            }
            
            // Product Details
            VStack(alignment: .leading, spacing: 8) {
                Text(product.productName)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(1)
                
                Text(product.productType)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 10)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
                
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("₹\(product.price.formatted())")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("+\(product.tax, specifier: "%.1f")%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                // Favorite Button
                Button(action: onFavorite) {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(product.isFavorite ? .red : .gray)
                        .frame(width: 38, height: 38)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(BorderlessButtonStyle())
                .scaleEffect(product.isFavorite ? 1.1 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: product.isFavorite)
                
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .padding(.horizontal, 12)
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
