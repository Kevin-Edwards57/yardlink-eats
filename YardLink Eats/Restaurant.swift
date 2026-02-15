//
//  Restaurant.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/19/26.
//
//


import Foundation
import CoreLocation

struct Restaurant: Identifiable, Hashable {
    let id: String

    let name: String
    let borough: String
    let address: String
    let latitude: Double
    let longitude: Double

    let mustTry: String?
    let phone: String?
    let website: String?
    let instagram: String?
    let isFeatured: Bool

    init(
        id: String,
        name: String,
        borough: String,
        address: String,
        latitude: Double,
        longitude: Double,
        mustTry: String? = nil,
        phone: String? = nil,
        website: String? = nil,
        instagram: String? = nil,
        isFeatured: Bool = false
    ) {
        self.id = id
        self.name = name
        self.borough = borough
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.mustTry = mustTry
        self.phone = phone
        self.website = website
        self.instagram = instagram
        self.isFeatured = isFeatured
    }

    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}

