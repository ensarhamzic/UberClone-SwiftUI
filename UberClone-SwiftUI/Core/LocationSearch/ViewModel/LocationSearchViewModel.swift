//
//  LocationSearchViewModel.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import Foundation
import MapKit

enum LocationStatus: Equatable {
    case idle
    case noResults
    case isSearching
    case error(String)
    case result
}

class LocationSearchViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Published private(set) var results = [MKLocalSearchCompletion]()
    @Published var selectedUberLocation: UberLocation?
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    var userLocation: CLLocationCoordinate2D?
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        self.searchCompleter.delegate = self
        self.searchCompleter.queryFragment = queryFragment
    }
    
    // MARK: - Helpers
    
//    func selectLocation(location: MKLocalSearchCompletion, forConfig config: LocationResultsViewConfig) {
//        switch config {
//        case .savedLocations(let option):
//            uploadSavedLocation(location: location, forOption: option)
//        case .ride:
//            self.selectedLocation = location
//
//            self.locationSearch(forLocalSearchCompletion: location) { response, error in
//                guard let item = response?.mapItems.first else { return }
//
//                let coordinate = item.placemark.coordinate
//                self.selectedUberLocation = UberLocation(title: location.title, coordinate: coordinate)
//            }
//        }
//    }
    
    func selectLocation(_ localSearch: MKLocalSearchCompletion) {
        locationSearch(forLocalSearchCompletion: localSearch) { response, error in
            if let error = error {
                print("ERROR \(error.localizedDescription)")
                return
            }
            guard let item = response?.mapItems.first else { return }
            let coordinate = item.placemark.coordinate
            self.selectedUberLocation = UberLocation(title: localSearch.title, coordinate: coordinate)
            
            print(coordinate)
        }
    }
    
    func selectSavedLocation(title: String, location: Location?) {
        var coordinate = CLLocationCoordinate2D()
        coordinate.latitude = location!.latitude
        coordinate.longitude = location!.longitude
        
        self.selectedUberLocation = UberLocation(title: title, coordinate: coordinate)
    }
    
    func selectCustomLocation(title: String, location: CLLocationCoordinate2D) {
        self.selectedUberLocation = UberLocation(title: title, coordinate: location)
    }

    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion,
                        completion: @escaping MKLocalSearch.CompletionHandler) {

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)

        search.start(completionHandler: completion)
    }
    
    func computeRidePrice(forType type: RideType) -> Double {
        guard let destCoordinate = selectedUberLocation?.coordinate else {return 0.0}
        guard let userCoordinate = self.userLocation else { return 0.0}
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let destination = CLLocation(latitude: destCoordinate.latitude, longitude: destCoordinate.longitude)
        
        let tripDistanceInMeters = userLocation.distance(from: destination)
        return type.computePrice(for: tripDistanceInMeters)
    }
    
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> Void) {
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        let destPlacemark = MKPlacemark(coordinate: destination)
        request.destination = MKMapItem(placemark: destPlacemark)
        let directions = MKDirections(request: request)
        
        directions.calculate {response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let route = response?.routes.first else { return }
            self.configurePickupAndDropoffTimes(with: route.expectedTravelTime)
            completion(route)
        }
    }
    
    
    func configurePickupAndDropoffTimes(with expectedTravelTime: Double) {
        let formatter =  DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickupTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTravelTime)
    }
}

// MARK: - API

//extension LocationSearchViewModel {
//    func uploadSavedLocation(location: MKLocalSearchCompletion, forOption option: SavedLocationOptions) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        self.locationSearch(forLocalSearchCompletion: location) { response, error in
//            guard let item = response?.mapItems.first else { return }
//
//            let coordinate = item.placemark.coordinate
//            let title = location.title
//            let address = location.subtitle
//
//            let data: [String: Any] = ["title": title,
//                                       "address": address,
//                                       "latitude": coordinate.latitude,
//                                       "longitude": coordinate.longitude] as [String : Any]
//
//            COLLECTION_USERS.document(uid).updateData([option.databaseKey: data])
//        }
//    }
//}
//
//// MARK: - MKLocalSearchCompleterDelegate
//
//
extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
//        self.status = completer.results.isEmpty ? .noResults : .result
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
//        self.status = .error(error.localizedDescription)
    }
}

