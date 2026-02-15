//
//  FirestoreBootstrapper.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/25/26.
//


import SwiftUI
import SwiftData

struct FirestoreBootstrapper: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        FirestoreTestView()
            .task {
                let descriptor = FetchDescriptor<RestaurantModel>()
                let local = (try? modelContext.fetch(descriptor)) ?? []
                print("📦 Local SwiftData restaurants:", local.count)

                FirestoreImporter.shared.uploadIfNeeded(from: local)
            }
    }
}
