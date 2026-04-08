//
//  ContentView.swift
//  YardLink Eats
//
//  Updated to include Yardie 🇯🇲 floating chatbot overlay
//
//
//  ContentView.swift
//  YardLink Eats
//
//  Updated to include Errol 🇯🇲 floating chatbot overlay
//
 
import SwiftUI
import SwiftData
 
struct ContentView: View {
 
    @Environment(\.modelContext) private var context
    @Query(sort: \RestaurantModel.name) private var models: [RestaurantModel]
 
    @State private var showAdd = false
    @State private var selectedTab = 1 // 0=Map, 1=List (RootView), 2=Favorites
 
    private var restaurants: [Restaurant] {
        models.map { $0.asRestaurant }
    }
 
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
 
            // ── Main Tab UI ──────────────────────────────────────────
            TabView(selection: $selectedTab) {
 
                // MAP TAB
                NavigationStack {
                    RestaurantMapView(restaurants: restaurants)
                        .navigationTitle("Map")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button { showAdd = true } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                }
                .tabItem { Label("Map", systemImage: "map") }
                .tag(0)
 
                // LIST TAB
                NavigationStack {
                    RootView()
                        .navigationTitle("YardLink Eats")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button { showAdd = true } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                }
                .tabItem { Label("List", systemImage: "list.bullet") }
                .tag(1)
 
                // FAVORITES TAB
                NavigationStack {
                    FavoritesView()
                        .navigationTitle("Favorites")
                }
                .tabItem { Label("Favorites", systemImage: "heart") }
                .tag(2)
            }
 
            // ── Errol Floating Chatbot Button ───────────────────────
            ErrolOverlay(restaurants: restaurants)
        }
        .sheet(isPresented: $showAdd) {
            AddRestaurantView()
        }
        .task {
            seedIfNeeded()
        }
    }
 
    private func seedIfNeeded() {
        guard models.isEmpty else { return }
 
        let seed: [RestaurantModel] = [
            RestaurantModel(
                name: "Tastee Jamaican Patties",
                borough: "Queens",
                address: "165-19 Jamaica Ave, Queens, NY",
                latitude: 40.7037,
                longitude: -73.7990,
                mustTry: "Beef patty + coco bread"
            ),
            RestaurantModel(
                name: "The Islands",
                borough: "Brooklyn",
                address: "671 Washington Ave, Brooklyn, NY",
                latitude: 40.6789,
                longitude: -73.9634,
                mustTry: "Oxtail"
            ),
            RestaurantModel(
                name: "Jerk House NYC",
                borough: "Manhattan",
                address: "Manhattan, NY",
                latitude: 40.7831,
                longitude: -73.9712,
                mustTry: "Jerk chicken"
            )
        ]
 
        seed.forEach { context.insert($0) }
    }
}
 
#Preview {
    ContentView()
        .modelContainer(for: RestaurantModel.self, inMemory: true)
        .environmentObject(FavoritesStore())
}
 
