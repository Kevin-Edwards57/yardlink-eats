//
//  AddRestaurantView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/19/26.
//



import SwiftUI

struct FirestoreTestView: View {
    @EnvironmentObject private var firestore: FirestoreService
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                if firestore.restaurants.isEmpty {
                    ContentUnavailableView(
                        "No restaurants yet",
                        systemImage: "fork.knife",
                        description: Text("Tap + to add one.")
                    )
                } else {
                    ForEach(firestore.restaurants) { r in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(r.name).font(.headline)
                            Text("\(r.borough) • \(r.address)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let mustTry = r.mustTry, !mustTry.isEmpty {
                                Text("Must try: \(mustTry)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Firestore Test")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear { firestore.startListening() }
            .onDisappear { firestore.stopListening() }
            .sheet(isPresented: $showAdd) {
                AddRestaurantView()
                    .environmentObject(firestore)
            }
        }
    }
}
