//
//  RestaurantListView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/21/26.
//



import SwiftUI

struct RestaurantListView: View {

    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var firestore: FirestoreService

    var body: some View {
        let restaurants = firestore.restaurants

        Group {
            if restaurants.isEmpty {
                ContentUnavailableView(
                    "No restaurants found",
                    systemImage: "fork.knife",
                    description: Text("If you approved docs in Firestore and still see nothing, it’s either filtering or Firestore rules.")
                )
                .padding()
            } else {
                List(restaurants) { r in
                    NavigationLink {
                        RestaurantDetailView(restaurant: r)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(r.name)
                                    .font(.headline)

                                Text("\(r.borough) • \(r.address)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            if favorites.isFavorite(r) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
