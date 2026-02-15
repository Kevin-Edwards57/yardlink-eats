//
//  RestaurantDetailView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/19/26.
//



import SwiftUI
import MapKit
import UIKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant

    @EnvironmentObject private var favorites: FavoritesStore
    @Environment(\.openURL) private var openURL

    @State private var showCallAlert = false
    @State private var callAlertMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                // iOS 17+ Map
                Map {
                    Marker(restaurant.name, coordinate: coordinate)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {

                    HStack(spacing: 8) {
                        Text(restaurant.name)
                            .font(.title2.bold())

                        if restaurant.isFeatured {
                            Text("⭐")
                        }
                    }

                    Text("\(restaurant.borough) • \(restaurant.address)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let mustTry = cleaned(restaurant.mustTry) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(.secondary)
                            Text("Must try: \(mustTry)")
                                .font(.subheadline)
                        }
                        .padding(.top, 2)
                    }

                    VStack(spacing: 10) {
                        Button { openInAppleMaps() } label: {
                            actionRow(icon: "map", title: "Open in Apple Maps")
                        }

                        if let phone = cleaned(restaurant.phone) {
                            Button { callPhone(phone) } label: {
                                actionRow(icon: "phone", title: "Call \(phone)")
                            }
                        }

                        if let website = cleaned(restaurant.website),
                           let url = normalizeURL(website) {
                            Button { openURL(url) } label: {
                                actionRow(icon: "globe", title: "Website")
                            }
                        }

                        if let ig = cleaned(restaurant.instagram),
                           let url = instagramURL(from: ig) {
                            Button { openURL(url) } label: {
                                actionRow(icon: "camera", title: "Instagram")
                            }
                        }

                        Button { favorites.toggle(restaurant) } label: {
                            actionRow(
                                icon: favorites.isFavorite(restaurant) ? "heart.fill" : "heart",
                                title: favorites.isFavorite(restaurant) ? "Remove Favorite" : "Save Favorite",
                                tintRed: favorites.isFavorite(restaurant)
                            )
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Call", isPresented: $showCallAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(callAlertMessage)
        }
    }

    // MARK: - Coordinate
    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
    }

    // MARK: - UI
    private func actionRow(icon: String, title: String, tintRed: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 24)

            Text(title).font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tintRed ? Color.red.opacity(0.35) : Color.primary.opacity(0.08), lineWidth: 1)
        )
        .foregroundStyle(tintRed ? .red : .primary)
    }

    // MARK: - Apple Maps
    private func openInAppleMaps() {
        if restaurant.latitude == 0 || restaurant.longitude == 0 {
            let q = "\(restaurant.name) \(restaurant.address)"
            let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? q
            if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
                openURL(url)
            }
            return
        }

        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = restaurant.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    // MARK: - Phone
    private func callPhone(_ phone: String) {
        let digits = phone.filter { $0.isNumber }

        guard !digits.isEmpty else {
            callAlertMessage = "No valid phone number to call."
            showCallAlert = true
            return
        }

        guard let url = URL(string: "tel://\(digits)") else {
            callAlertMessage = "Phone number format is invalid."
            showCallAlert = true
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            callAlertMessage = "Calls don’t work on the Simulator. Run on a real iPhone."
            showCallAlert = true
        }
    }

    // MARK: - Helpers (FIXED: accepts String?)
    private func cleaned(_ s: String?) -> String? {
        guard let s else { return nil }
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    private func normalizeURL(_ raw: String) -> URL? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.lowercased().hasPrefix("http://") || t.lowercased().hasPrefix("https://") {
            return URL(string: t)
        }
        return URL(string: "https://\(t)")
    }

    private func instagramURL(from raw: String) -> URL? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return nil }

        if let url = normalizeURL(t), url.host != nil {
            return url
        }

        let handle = t.replacingOccurrences(of: "@", with: "")
        return URL(string: "https://instagram.com/\(handle)")
    }
}
