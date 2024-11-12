//
//  MainTabView.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 10/11/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = "Products"
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                tabView()
            } else {
                navigationSplitView()  // NavigationSplitView for Devices(like iPad) with larger screens
            }
        }
    }
    
   
    private func tabView() -> some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ProductList()
            }
            .tag("Products")
            .tabItem {
                VStack {
                    Image(systemName: "bag.fill")
                    Text("Products")
                }
            }
            
            NavigationView {
                AddProduct()
            }
            .tag("Add")
            .tabItem {
                VStack {
                    Image(systemName: "plus")
                    Text("Add")
                }
            }
        }
    }
    
   
    private func navigationSplitView() -> some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: ProductList()) {
                    Label("Products", systemImage: "bag.fill")
                }
                
                NavigationLink(destination: AddProduct()) {
                    Label("Add", systemImage: "plus")
                }
            }
            .navigationTitle("Product Management")
        } detail: {
            ProductList()
        }
    }
}

#Preview {
    MainTabView()
}
