//
//  FavoritesStore.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/20/26.
//


import Foundation
import SwiftUI

final class FavoritesStore: ObservableObject {

    @AppStorage("favoriteRestaurantIDs")
    private var storedIDs: String = ""

    @Published private(set) var favorites: Set<String> = []

    init() {
        load()
    }

    func isFavorite(_ restaurant: Restaurant) -> Bool {
        favorites.contains(restaurant.id)
    }

    func toggle(_ restaurant: Restaurant) {
        if favorites.contains(restaurant.id) {
            favorites.remove(restaurant.id)
        } else {
            favorites.insert(restaurant.id)
        }
        persist()
    }

    private func load() {
        let ids = storedIDs
            .split(separator: ",")
            .map(String.init)
            .filter { !$0.isEmpty }

        favorites = Set(ids)
    }

    private func persist() {
        storedIDs = favorites.joined(separator: ",")
    }
}
