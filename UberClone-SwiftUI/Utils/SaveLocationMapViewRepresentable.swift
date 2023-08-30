//
//  SavedLocationMapViewRepresentable.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 26.08.23.
//

import SwiftUI
import MapKit

struct SaveLocationMapViewRepresentable: UIViewRepresentable {
    let mapView = MKMapView()
    var mapTapped: (_ coordinate: CLLocationCoordinate2D) -> Void
    let savedCoordinate: Location?
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.centerOnUserLocation()
        
        if savedCoordinate != nil {
            print(savedCoordinate!)
            let ant = MKPointAnnotation()
            var coord = CLLocationCoordinate2D()
            coord.latitude = savedCoordinate!.latitude
            coord.longitude = savedCoordinate!.longitude
            ant.coordinate = coord
            mapView.addAnnotation(ant)
        }
    }
    
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        return mapView
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
    
}

extension SaveLocationMapViewRepresentable {
    class MapCoordinator: NSObject, MKMapViewDelegate  {
        
        // MARK: - Properties
        
        let parent: SaveLocationMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        
        var currentRegion: MKCoordinateRegion?
        //        var userLocation: MKUserLocation?
        //        var didSetVisibleMapRectForTrip = false
        
        //        private var drivers = [User]()
        
        // MARK: - Lifecycle
        
        init(parent: SaveLocationMapViewRepresentable) {
            self.parent = parent
            super.init()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            parent.mapView.addGestureRecognizer(tapGesture)
            
            
        }
        
        @objc func handleTap(gestureReconizer: UITapGestureRecognizer) {
            
            let location = gestureReconizer.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location,toCoordinateFrom: parent.mapView)
            
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            parent.mapTapped(coordinate)
            
            /* to show only one pin while tapping on map by removing the last.
             If you want to show multiple pins you can remove this piece of code */
            if parent.mapView.annotations.count > 0 {
                print("Izbrisane anotacije")
                parent.mapView.removeAnnotations(parent.mapView.annotations)
            }
            
            parent.mapView.addAnnotation(annotation) // add annotaion pin on the map
        }
        
        // MARK: - MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            self.userLocationCoordinate = userLocation.coordinate
            // this will cause mapview to constantly center if user is changing location
            //            self.userLocation = userLocation
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            self.currentRegion = region
            
            //            if let user = parent.homeViewModel.user, user.accountType == .driver {
            //                parent.homeViewModel.updateDriverLocation(withCoordinate: userLocation.coordinate)
            //            }
            
            parent.mapView.setRegion(region, animated: true)
        }
        
        
        func centerOnUserLocation() {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
            if let currentRegion = currentRegion {
                parent.mapView.setRegion(currentRegion, animated: true)
            }
        }
    }
}
