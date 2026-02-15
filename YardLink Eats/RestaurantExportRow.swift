//
//  RestaurantExportRow.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/23/26.
//


import SwiftUI

// ✅ Export shape (matches your restaurants.json format)
struct RestaurantExportRow: Codable {
    let name: String
    let borough: String
    let address: String
    let latitude: Double
    let longitude: Double
    let must: String?        // <-- we export as "must" to match your JSON key
    let phone: String?
    let website: String?
    let instagram: String?
}

enum RestaurantExporter {

    static func makeJSONString(from models: [RestaurantModel]) -> String {
        let rows: [RestaurantExportRow] = models.map { m in
            RestaurantExportRow(
                name: m.name,
                borough: m.borough,
                address: m.address,
                latitude: m.latitude,
                longitude: m.longitude,
                must: clean(m.mustTry),
                phone: clean(m.phone),
                website: clean(m.website),
                instagram: clean(m.instagram)
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(rows)
            return String(decoding: data, as: UTF8.self)
        } catch {
            return "❌ Export failed: \(error)"
        }
    }

    private static func clean(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

// ✅ Simple exporter UI: shows JSON + copy button
struct ExportJSONSheet: View {
    let jsonText: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Copy this JSON and save it. This is your backup.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ScrollView {
                    Text(jsonText)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)
                }
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button("Copy JSON") {
                        UIPasteboard.general.string = jsonText
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("Export JSON")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
