//
//  LocationManager.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import CoreLocation

//enum RegionType: String {
//    case pickup
//    case dropoff
//}

class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Helpers
    private let locationManager = CLLocationManager()
    static let shared = LocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
//    @Published var didEnterPickupRegion = false
//    @Published var didEnterDropoffRegion = false
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Helpers
    
//    private func createCustomRegion(withType type: RegionType, coordinates: CLLocationCoordinate2D) {
//        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
//        locationManager.startMonitoring(for: region)
//    }
//
//    func createPickupRegionForTrip(_ trip: Trip) {
//        print("DEBUG: Did create pickup region..")
//        createCustomRegion(withType: .pickup, coordinates: trip.pickupLocationCoordiantes)
//    }
//
//    func createDropoffRegionForTrip(_ trip: Trip) {
//        print("DEBUG: Did create dropoff region..")
//        createCustomRegion(withType: .dropoff, coordinates: trip.dropoffLocationCoordinates)
//    }
    
    
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        self.userLocation = location.coordinate
//        locationManager.stopUpdatingLocation()
    }
//
//    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        if region.identifier == RegionType.pickup.rawValue {
//            print("DEBUG: Did start montioring pick up region \(region)")
//        }
//
//        if region.identifier == RegionType.dropoff.rawValue {
//            print("DEBUG: Did start montioring destination region \(region)")
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        if region.identifier == RegionType.pickup.rawValue {
//            print("DEBUG: Did enter region..")
//            didEnterPickupRegion = true
//        }
//
//        if region.identifier == RegionType.dropoff.rawValue {
//            print("DEBUG: Did start montioring destination region \(region)")
//            didEnterDropoffRegion = true
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        if region.identifier == RegionType.pickup.rawValue {
//            print("DEBUG: Did exit pickup region")
//            didEnterPickupRegion = false
//        }
//
//        if region.identifier == RegionType.dropoff.rawValue {
//            didEnterDropoffRegion = false
//        }
//    }
}
