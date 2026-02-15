//
//  ContentView.swift
//  YardLink Eats
//


import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var firestore: FirestoreService

    var body: some View {
        TabView {
            NavigationStack {
                RootView()
            }
            .tabItem { Label("Home", systemImage: "fork.knife") }

            NavigationStack {
                FavoritesView()
            }
            .tabItem { Label("Favorites", systemImage: "heart.fill") }
        }
        .onAppear {
            firestore.startListening()
        }
    }
}

