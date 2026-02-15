//
//  FirestoreImporter.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/25/26.
//


import Foundation
import FirebaseFirestore

final class FirestoreImporter {
    static let shared = FirestoreImporter()
    private init() {}

    private let db = Firestore.firestore()

    func uploadIfNeeded(from localRestaurants: [RestaurantModel]) {
        db.collection("restaurants").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to check Firestore:", error.localizedDescription)
                return
            }

            let existingCount = snapshot?.documents.count ?? 0
            if existingCount > 0 {
                print("ℹ️ Import skipped. Firestore already has \(existingCount) restaurants.")
                return
            }

            if localRestaurants.isEmpty {
                print("⚠️ Local SwiftData is empty. Nothing to upload.")
                return
            }

            print("🚀 Uploading \(localRestaurants.count) restaurants to Firestore...")

            let batch = self.db.batch()

            for r in localRestaurants {
                // Use your UUID as the Firestore doc id so it stays stable
                let ref = self.db.collection("restaurants").document(r.id.uuidString)

                batch.setData([
                    "name": r.name,
                    "borough": r.borough,
                    "address": r.address,
                    "latitude": r.latitude,
                    "longitude": r.longitude,
                    "mustTry": r.mustTry ?? "",
                    "phone": r.phone ?? "",
                    "website": r.website ?? "",
                    "instagram": r.instagram ?? ""
                ], forDocument: ref)
            }

            batch.commit { err in
                if let err = err {
                    print("❌ Upload failed:", err.localizedDescription)
                } else {
                    print("✅ Upload complete. Firestore now has data.")
                }
            }
        }
    }
}
