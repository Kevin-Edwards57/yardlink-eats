//
//  RestaurantRowView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/23/26.
//


//
//  RestaurantRowView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/23/26.
//

import SwiftUI

struct RestaurantRowView: View {
    let r: Restaurant
    let isFavorite: Bool

    private var mustTryText: String {
        (r.mustTry ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {

                HStack(spacing: 8) {
                    Text(r.name)
                        .font(.headline)

                    if r.isFeatured {
                        Text("⭐")
                            .font(.subheadline)
                    }
                }

                Text(r.borough)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !mustTryText.isEmpty {
                    Text("Must try: \(mustTryText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 6)
    }
}
