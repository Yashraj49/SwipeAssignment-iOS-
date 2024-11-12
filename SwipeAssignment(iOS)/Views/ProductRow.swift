//
//  ProductRow.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 10/11/24.
//

import SwiftUI

struct ProductRow: View {
    let product: Product
    let onFavorite: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var totalPrice: Double {
        product.price * (1 + product.tax/100)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Product Image
            AsyncImage(url: URL(string: product.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                    )
            } placeholder: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.1))
                    .frame(width: 75, height: 75)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    )
            }
            
            // Product Details
            VStack(alignment: .leading, spacing: 6) {
                Text(product.productName)
                    .font(.system(size: 17, weight: .medium))
                    .lineLimit(1)
                
                Text(product.productType)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(Capsule())
                
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("₹\(product.price.formatted())")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Text("+\(product.tax, specifier: "%.1f")%")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary.opacity(0.9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: onFavorite) {
                Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 17))
                    .foregroundColor(product.isFavorite ? .red : .gray)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(BorderlessButtonStyle())
            .scaleEffect(product.isFavorite ? 1.05 : 1.0)
            .animation(.spring(response: 0.2), value: product.isFavorite)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
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
