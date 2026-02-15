//
//  YardLink_EatsApp.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/19/26.
//
import SwiftUI
import SwiftData
import FirebaseCore

@main
struct YardLink_EatsApp: App {

    @StateObject private var favoritesStore = FavoritesStore()
    @StateObject private var firestoreService = FirestoreService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SplashGateView()
                .environmentObject(favoritesStore)
                .environmentObject(firestoreService)
        }
        .modelContainer(for: RestaurantModel.self)
    }
}
