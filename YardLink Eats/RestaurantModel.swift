//
//  RestaurantModel.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/19/26.
//


//
//  RestaurantModel.swift
//  YardLink Eats
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class RestaurantModel {
    var id: UUID
    var name: String
    var borough: String
    var address: String
    var latitude: Double
    var longitude: Double
    var mustTry: String?

    var phone: String?
    var website: String?
    var instagram: String?

    init(
        name: String,
        borough: String,
        address: String,
        latitude: Double,
        longitude: Double,
        mustTry: String? = nil,
        phone: String? = nil,
        website: String? = nil,
        instagram: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.borough = borough
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.mustTry = mustTry
        self.phone = phone
        self.website = website
        self.instagram = instagram
    }

    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}

extension RestaurantModel {
    var asRestaurant: Restaurant {
        Restaurant(
            id: id.uuidString,                 // ✅ UUID -> String
            name: name,
            borough: borough,
            address: address,
            latitude: latitude,
            longitude: longitude,
            mustTry: mustTry,
            phone: phone,
            website: website,
            instagram: instagram,
            isFeatured: false                  // ✅ SwiftData doesn’t have this field
        )
    }
}
