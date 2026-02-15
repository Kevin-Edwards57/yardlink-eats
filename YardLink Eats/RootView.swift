//
//  ContentView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/19/26.
//


import SwiftUI
import CoreLocation

struct RootView: View {

    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var firestore: FirestoreService

    @State private var selectedBorough: String? = nil
    @State private var searchText = ""
    @State private var showMap = false
    @State private var showAdd = false

    private let boroughs = ["Brooklyn", "Queens", "Bronx", "Manhattan"]

    private var filteredRestaurants: [Restaurant] {
        firestore.restaurants.filter {
            (selectedBorough == nil || $0.borough == selectedBorough) &&
            (searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()))
        }
    }

    var body: some View {
        VStack(spacing: 12) {

            // Borough chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button("All NYC") { selectedBorough = nil }
                        .buttonStyle(.bordered)
                        .tint(selectedBorough == nil ? .blue : .gray)

                    ForEach(boroughs, id: \.self) { b in
                        Button(b) { selectedBorough = b }
                            .buttonStyle(.bordered)
                            .tint(selectedBorough == b ? .blue : .gray)
                    }
                }
                .padding(.horizontal)
            }

            // Search
            HStack {
                TextField("Search restaurants", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            // List / Empty
            if filteredRestaurants.isEmpty {
                ContentUnavailableView("No restaurants found", systemImage: "fork.knife")
                    .padding(.top, 40)
            } else {
                List(filteredRestaurants) { r in
                    NavigationLink {
                        RestaurantDetailView(restaurant: r)
                    } label: {
                        RestaurantRowView(
                            r: r,
                            isFavorite: favorites.isFavorite(r)
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("YardLink Eats")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showAdd = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button { showMap = true } label: {
                    Label("Map", systemImage: "map")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddRestaurantView()
                .environmentObject(firestore)
        }
        .sheet(isPresented: $showMap) {
            NavigationStack {
                RestaurantMapView(restaurants: filteredRestaurants)
                    .navigationTitle("Map")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close") { showMap = false }
                        }
                    }
            }
        }
        .task {
            firestore.startListening()
        }
        .onDisappear {
            firestore.stopListening()
        }
    }
}
