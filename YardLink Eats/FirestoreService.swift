import Foundation
import FirebaseFirestore

@MainActor
final class FirestoreService: ObservableObject {

    @Published var restaurants: [Restaurant] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // ✅ LIVE collection only
    private let collectionName = "restaurants"

    init() {
        startListening()
    }

    // ✅ FIX: deinit can't call @MainActor isolated methods
    deinit {
        listener?.remove()
        listener = nil
    }

    // MARK: - LISTEN FOR APPROVED RESTAURANTS
    func startListening() {
        stopListening()

        listener = db.collection(collectionName)
            .whereField("approved", isEqualTo: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("🔥 Firestore listen error:", err.localizedDescription)
                    return
                }

                guard let docs = snap?.documents else {
                    self.restaurants = []
                    return
                }

                let mapped: [Restaurant] = docs.compactMap { doc in
                    let data = doc.data()

                    let name = (data["name"] as? String)?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if name.isEmpty { return nil }

                    guard
                        let latitude = data["latitude"] as? Double,
                        let longitude = data["longitude"] as? Double
                    else { return nil }

                    let borough = data["borough"] as? String ?? "Unknown"
                    let address = data["address"] as? String ?? ""

                    let mustTry = data["mustTry"] as? String
                    let phone = data["phone"] as? String
                    let website = data["website"] as? String
                    let instagram = data["instagram"] as? String
                    let isFeatured = data["isFeatured"] as? Bool ?? false

                    return Restaurant(
                        id: doc.documentID,
                        name: name,
                        borough: borough,
                        address: address,
                        latitude: latitude,
                        longitude: longitude,
                        mustTry: mustTry,
                        phone: phone,
                        website: website,
                        instagram: instagram,
                        isFeatured: isFeatured
                    )
                }

                self.restaurants = mapped
                print("✅ Loaded approved restaurants:", mapped.count)
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - ADD RESTAURANT (MANUAL = AUTO APPROVED)
    func addRestaurant(
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
        let payload: [String: Any] = [
            "name": name,
            "borough": borough,
            "address": address,
            "latitude": latitude,
            "longitude": longitude,
            "mustTry": mustTry ?? "",
            "phone": phone ?? "",
            "website": website ?? "",
            "instagram": instagram ?? "",
            "isFeatured": isFeatured,

            // ✅ manual adds should show immediately
            "approved": true,

            // metadata
            "category": "unknown",
            "source": "manual",
            "updatedAt": Timestamp(date: Date())
        ]

        db.collection(collectionName).addDocument(data: payload) { err in
            if let err = err {
                print("🔥 Error adding restaurant:", err.localizedDescription)
            } else {
                print("✅ Restaurant added and approved")
            }
        }
    }
}

