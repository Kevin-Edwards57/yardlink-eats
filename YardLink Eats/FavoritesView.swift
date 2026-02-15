//
//  FavoritesView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/21/26.
//
//
//  FavoritesView.swift
//  YardLink Eats
//

import SwiftUI

struct FavoritesView: View {

    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var firestore: FirestoreService

    private var favoriteRestaurants: [Restaurant] {
        firestore.restaurants
            .filter { favorites.isFavorite($0) }
            .sorted { a, b in
                a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            }
    }

    var body: some View {
        Group {
            if favoriteRestaurants.isEmpty {
                ContentUnavailableView(
                    "No favorites yet",
                    systemImage: "heart",
                    description: Text("Tap the heart on a restaurant to save it here.")
                )
                .padding()
            } else {
                List(favoriteRestaurants) { r in
                    NavigationLink {
                        RestaurantDetailView(restaurant: r)
                    } label: {
                        RestaurantRowView(r: r, isFavorite: true)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
    }
}

