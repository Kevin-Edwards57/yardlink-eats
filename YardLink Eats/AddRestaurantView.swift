import SwiftUI
import CoreLocation

struct AddRestaurantView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestore: FirestoreService

    // Form fields
    @State private var name = ""
    @State private var borough = ""
    @State private var address = ""
    @State private var mustTry = ""

    @State private var phone = ""
    @State private var website = ""
    @State private var instagram = ""
    @State private var isFeatured = false

    @StateObject private var locationManager = LocationManager()

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !borough.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            
            Form {
                Section("Basics") {
                    TextField("Name", text: $name)
                    TextField("Borough", text: $borough)
                    TextField("Address", text: $address)
                    TextField("Must try", text: $mustTry)
                    Toggle("⭐ Featured", isOn: $isFeatured)
                }

                Section("Contact") {
                    TextField("Phone", text: $phone)
                    TextField("Website", text: $website)
                    TextField("Instagram", text: $instagram)
                }

                Section("Location") {
                    Button("Use my current location") {
                        locationManager.request()
                    }

                    if let c = locationManager.lastCoordinate {
                        Text("Lat: \(c.latitude)")
                        Text("Lng: \(c.longitude)")
                    } else {
                        Text("No location yet")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add Restaurant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let lat = locationManager.lastCoordinate?.latitude ?? 0
                        let lng = locationManager.lastCoordinate?.longitude ?? 0

                        firestore.addRestaurant(
                            name: name,
                            borough: borough,
                            address: address,
                            latitude: lat,
                            longitude: lng,
                            mustTry: mustTry.isEmpty ? nil : mustTry,
                            phone: phone.isEmpty ? nil : phone,
                            website: website.isEmpty ? nil : website,
                            instagram: instagram.isEmpty ? nil : instagram,
                            isFeatured: isFeatured
                        )

                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            // optional: auto-request on open
            // locationManager.request()
        }
    }
}

// MARK: - Location Manager
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var lastCoordinate: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func request() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastCoordinate = locations.last?.coordinate
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 Location error:", error.localizedDescription)
    }
}

