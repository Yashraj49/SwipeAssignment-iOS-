//
//  AddProduct.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 10/11/24.
//

import SwiftUI

enum ProductType: String, CaseIterable {
    case electronics = "Electronics"
    case phone = "Phone"
    case laptop = "Laptop"
    case clothing = "Clothing"
    case tShirt = "T-Shirt"
    case pants = "Pants"
    case food = "Food"
    case fruit = "Fruit"
    case vegetables = "Vegetables"
    case stationery = "Stationery"
    case pen = "Pen"
    case notebook = "Notebook"
    case mobile = "Mobile"
    case accessories = "Accessories"
    case furniture = "Furniture"
}

struct AddProduct: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedType = ProductType.phone
    @State var productNameString = ""
    @State var productPriceDouble: Double = 0.0
    @State var productTaxDouble: Double = 0.0
    @State var isFavorite : Bool = false
    @ObservedObject var viewModel = Manager()
    
     func handleAddProduct() {
        let newProduct = Product(
            productName: productNameString,
            productType: selectedType.rawValue,
            price: productPriceDouble,
            tax: productTaxDouble,
            image: "",
            isFavorite: isFavorite
        )
        
        Task {
            await viewModel.addProduct(newProduct)
        }
        
        selectedType = .phone
        productNameString = ""
        productPriceDouble = 0
        productTaxDouble = 0
    }
    
    var body: some View {
       
            Form {
                // category Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "tag.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 18))
                            .frame(width: 24)
                            .symbolEffect(.bounce, options: .repeat(2), value: selectedType)
                        
                        Picker("Product Type", selection: $selectedType) {
                            ForEach(ProductType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Category")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                
                // product Details Section
                Section {
                    VStack(spacing: 16) {
                       
                        HStack(spacing: 12) {
                            Image(systemName: "cube.box.fill")
                                .foregroundStyle(.blue)
                                .font(.system(size: 18))
                                .frame(width: 24)
                                .symbolEffect(.bounce, options: .repeat(1), value: productNameString)
                            
                            TextField("Product Name", text: $productNameString)
                                .textInputAutocapitalization(.words)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // price
                        HStack(spacing: 12) {
                            Image(systemName: "indianrupeesign.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.system(size: 18))
                                .frame(width: 24)
                                .symbolEffect(.bounce, options: .repeat(1), value: productPriceDouble)
                            
                            TextField("Price", value: $productPriceDouble, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(productPriceDouble < 0 ? Color.red : Color.clear, lineWidth: 1)
                                )
                        }
                        
                        // Tax Rate
                        HStack(spacing: 12) {
                            Image(systemName: "percent")
                                .foregroundStyle(.blue)
                                .font(.system(size: 18))
                                .frame(width: 24)
                                .symbolEffect(.bounce, options: .repeat(1), value: productTaxDouble)
                            
                            TextField("Tax Rate", value: $productTaxDouble, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(productTaxDouble < 0 ? Color.red : Color.clear, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Product Details")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.blue)
                } footer: {
                    Text("Enter all details carefully. Price and tax rate must be valid numbers.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                // add Button Section
                Section {
                    Button(action: handleAddProduct) {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.medium)
                            Text("Add Product")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(disabled ? .gray : .white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(disabled ? Color.gray.opacity(0.3) : Color.blue)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                .disabled(disabled)
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.large)
            .scrollDismissesKeyboard(.interactively)
        
        .alert("Action Completed", isPresented: $viewModel.showAlert) {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }
        } message: {
            Text(viewModel.alertDescription)
        }
    }
    var disabled: Bool {
        return productNameString.isEmpty || productPriceDouble <= 0 || productTaxDouble > 100
    }
    
}

#Preview {
    NavigationView {
        AddProduct()
    }
}
