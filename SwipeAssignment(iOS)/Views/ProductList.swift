//
//  ProductList.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 10/11/24.
//

import SwiftUI

struct ProductList: View {
    @StateObject var viewModel = Manager()
    @State var searchText = ""
    @State var showAddProduct = false
    @State var showAlert = false
    
    var allProducts: [Product] {
        viewModel.products + viewModel.offlineProducts
    }
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return allProducts
        }
        return allProducts.filter {
            $0.productName.lowercased().contains(searchText.lowercased()) ||
            $0.productType.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Search Bar
                    CustomSearchBar(text: $searchText)
                    
                    ScrollView {
                        VStack(spacing: Constants.List.rowSpacing) {
                            ForEach(filteredProducts, id: \.self) { product in
                                ProductRow(product: product) {
                                    withAnimation(.spring(response: 0.3)) {
                                        viewModel.toggleFavorite(product)
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                                .padding(Constants.List.rowInsets)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                        .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Products")
            // Remove the .searchable() modifier since we're using custom search bar
            .toolbar {
                // Your toolbar items remain the same
            }
            .task {
                await viewModel.getProducts()
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showAddProduct) {
                AddProduct()
            }
        }
    }


#Preview {
    NavigationView {
        ProductList()
    }
}


private enum Constants {
    enum SearchBar {
        static let height: CGFloat = 45
        static let cornerRadius: CGFloat = 15
        static let iconSize: CGFloat = 16
        static let clearButtonSize: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        static let spacing: CGFloat = 12
    }
    
    enum List {
        static let rowSpacing: CGFloat = 12
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let headerHeight: CGFloat = 36
    }
}


struct CustomSearchBar: View {
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: Constants.SearchBar.spacing) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: Constants.SearchBar.iconSize, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField("Search products...", text: $text)
                .font(.system(size: 16))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Constants.SearchBar.clearButtonSize))
                        .foregroundColor(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, Constants.SearchBar.horizontalPadding)
        .frame(height: Constants.SearchBar.height)
        .background(
            RoundedRectangle(cornerRadius: Constants.SearchBar.cornerRadius)
                .fill(colorScheme == .dark ? Color(.tertiarySystemBackground) : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.SearchBar.cornerRadius)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, Constants.SearchBar.horizontalPadding)
        .padding(.vertical, Constants.SearchBar.verticalPadding)
    }
}
