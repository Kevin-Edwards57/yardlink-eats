//
//  EditRestaurantView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/25/26.
//


import SwiftUI

struct EditRestaurantView: View {

    let restaurant: Restaurant
    let onSave: (_ updates: [String: Any]) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var borough: String
    @State private var address: String

    @State private var phone: String
    @State private var website: String
    @State private var instagram: String
    @State private var mustTry: String
    @State private var isFeatured: Bool

    @State private var latitudeText: String
    @State private var longitudeText: String

    init(restaurant: Restaurant, onSave: @escaping (_ updates: [String: Any]) -> Void) {
        self.restaurant = restaurant
        self.onSave = onSave

        _name = State(initialValue: restaurant.name)
        _borough = State(initialValue: restaurant.borough)
        _address = State(initialValue: restaurant.address)

        _phone = State(initialValue: restaurant.phone ?? "")
        _website = State(initialValue: restaurant.website ?? "")
        _instagram = State(initialValue: restaurant.instagram ?? "")
        _mustTry = State(initialValue: restaurant.mustTry ?? "")
        _isFeatured = State(initialValue: restaurant.isFeatured)

        _latitudeText = State(initialValue: String(restaurant.latitude))
        _longitudeText = State(initialValue: String(restaurant.longitude))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Name", text: $name)
                    TextField("Borough", text: $borough)
                    TextField("Address", text: $address)
                }

                Section("Coordinates") {
                    TextField("Latitude", text: $latitudeText)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitudeText)
                        .keyboardType(.decimalPad)
                }

                Section("Links") {
                    TextField("Phone", text: $phone)
                    TextField("Website", text: $website)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    TextField("Instagram", text: $instagram)
                        .textInputAutocapitalization(.never)
                }

                Section("Food") {
                    TextField("Must Try", text: $mustTry)
                    Toggle("Featured", isOn: $isFeatured)
                }
            }
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let lat = Double(latitudeText) ?? restaurant.latitude
                        let lon = Double(longitudeText) ?? restaurant.longitude

                        let updates: [String: Any] = [
                            "name": name,
                            "borough": borough,
                            "address": address,
                            "latitude": lat,
                            "longitude": lon,
                            "phone": phone,
                            "website": website,
                            "instagram": instagram,
                            "mustTry": mustTry,
                            "isFeatured": isFeatured
                        ]

                        onSave(updates)
                        dismiss()
                    }
                }
            }
        }
    }
}
