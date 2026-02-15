//
//  RestaurantJSONRow.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/23/26.
//


import Foundation
import SwiftData

// Matches restaurants.json exactly
// This version maps "must" -> mustTry
struct RestaurantJSONRow: Codable {
    let name: String
    let borough: String
    let address: String
    let latitude: Double?
    let longitude: Double?
    let mustTry: String?
    let phone: String?
    let website: String?
    let instagram: String?

    // 🔑 Map JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case name
        case borough
        case address
        case latitude
        case longitude
        case mustTry = "must"   // 👈 THIS IS THE FIX
        case phone
        case website
        case instagram
    }
}

enum RestaurantJSONImporter {

    /// Imports restaurants.json ONLY when SwiftData DB is empty
    static func importIfEmpty(
        modelContext: ModelContext,
        existingCount: Int
    ) {
        guard existingCount == 0 else {
            print("ℹ️ Import skipped. DB already has \(existingCount) restaurants.")
            return
        }

        guard let url = Bundle.main.url(
            forResource: "restaurants",
            withExtension: "json"
        ) else {
            print("❌ restaurants.json not found in app bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let rows = try JSONDecoder().decode([RestaurantJSONRow].self, from: data)

            for r in rows {
                let model = RestaurantModel(
                    name: r.name,
                    borough: r.borough,
                    address: r.address,
                    latitude: r.latitude ?? 0,
                    longitude: r.longitude ?? 0,
                    mustTry: clean(r.mustTry),
                    phone: clean(r.phone),
                    website: clean(r.website),
                    instagram: clean(r.instagram)
                )
                modelContext.insert(model)
            }

            try modelContext.save()
            print("✅ Imported \(rows.count) restaurants from restaurants.json")

        } catch {
            print("❌ JSON import failed:", error)
        }
    }

    // Converts empty strings to nil
    private static func clean(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
