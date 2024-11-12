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
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return viewModel.products
        }
        return viewModel.products.filter {
            $0.productName.lowercased().contains(searchText.lowercased()) ||
            $0.productType.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredProducts) { product in
                            ProductRow(product: product) {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.toggleFavorite(product)
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(.vertical)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.15))
                        .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await viewModel.getProducts()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 36, height: 36)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.isLoading)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddProduct = true
                    } label: {
                        Text("Add")
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search products...")
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
