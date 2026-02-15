//
//  RestaurantMapView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/20/26.
//

import SwiftUI
import MapKit

struct RestaurantMapView: View {

    let restaurants: [Restaurant]
    @EnvironmentObject private var favorites: FavoritesStore

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedID: String? = nil

    private var selectedRestaurant: Restaurant? {
        guard let selectedID else { return nil }
        return restaurants.first(where: { $0.id == selectedID })
    }

    var body: some View {
        Map(position: $position, selection: $selectedID) {
            ForEach(restaurants) { r in
                Marker(r.name, coordinate: r.coordinate)
                    .tag(r.id)
            }
        }
        .overlay(alignment: .bottom) {
            if let r = selectedRestaurant {
                bottomCard(r)
                    .padding()
            }
        }
    }

    private func bottomCard(_ r: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(r.name).font(.headline)
                    Text("\(r.borough) • \(r.address)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    favorites.toggle(r)
                } label: {
                    Image(systemName: favorites.isFavorite(r) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(favorites.isFavorite(r) ? .red : .primary)
                        .padding(8)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                NavigationLink {
                    RestaurantDetailView(restaurant: r)
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("View Details").fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
