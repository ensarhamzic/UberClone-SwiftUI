//
//  UberMapViewRepresentable.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI
import MapKit

struct UberMapViewRepresentable: UIViewRepresentable {
    let mapView = MKMapView()
    @Binding var mapState: MapViewState
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    @EnvironmentObject var webSocketViewModel: WebSocketViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var locationChosen: (_ coordinate: CLLocationCoordinate2D) -> Void
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        switch mapState {
        case .noInput:
            context.coordinator.clearMapViewAndRecenterOnUserLocation()
            if authViewModel.user?.type == .passenger {
                context.coordinator.addDriversToMap(webSocketViewModel.userLocations)
            }
            break
        case .searchingForLocation:
            break
        case .locationSelected:
            if let coordinate = locationViewModel.selectedUberLocation?.coordinate {
                context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate)
                context.coordinator.configurePolyline(withDestinationCoordinate: coordinate)
            }
        case .polylineAdded:
            break
        default:
            print("ensar")
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}


extension UberMapViewRepresentable {
    
    class MapCoordinator: NSObject, MKMapViewDelegate {
        
        // MARK: - Properties
        
        let parent: UberMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        
        var currentRegion: MKCoordinateRegion?
        //        var userLocation: MKUserLocation?
        //        var didSetVisibleMapRectForTrip = false
        
        //        private var drivers = [User]()
        
        // MARK: - Lifecycle
        
        init(parent: UberMapViewRepresentable) {
            self.parent = parent
            super.init()
            
            let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
            parent.mapView.addGestureRecognizer(tapGesture)
        }
        
        @objc func handleTap(gestureReconizer: UITapGestureRecognizer) {
            
            let location = gestureReconizer.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location,toCoordinateFrom: parent.mapView)
            
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            parent.locationChosen(coordinate)
            
            //            /* to show only one pin while tapping on map by removing the last.
            //             If you want to show multiple pins you can remove this piece of code */
            //            if parent.mapView.annotations.count > 0 {
            //                let randomNumber = Int.random(in: 1...100) // Change the range as needed
            //                print("Random number:", randomNumber)
            //                parent.mapView.removeAnnotations(parent.mapView.annotations)
            //            }
            //
            //            parent.mapView.addAnnotation(annotation) // add annotaion pin on the map
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
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let userLocationCoordinate = self.userLocationCoordinate else {return }
            parent.locationViewModel.getDestinationRoute(from: userLocationCoordinate, to: coordinate) { route in
                self.parent.mapView.addOverlay(route.polyline)
                self.parent.mapState = .polylineAdded
                let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect, edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32))
                
                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? DriverAnnotation {
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "driver")
                view.image = UIImage(named: "chevron-sign-to-right")
                return view
            }
            
            return nil
        }
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            
            let anno = MKPointAnnotation()
            anno.coordinate = coordinate
            
            self.parent.mapView.addAnnotation(anno)
            self.parent.mapView.selectAnnotation(anno, animated: true)
            
        }
        
        func clearMapViewAndRecenterOnUserLocation() {
            let annotationsToRemove = parent.mapView.annotations.filter { annotation in
                if let anno = annotation as? DriverAnnotation {
                    return false
                }
                return true
            }
            parent.mapView.removeAnnotations(annotationsToRemove)
            parent.mapView.removeOverlays(parent.mapView.overlays)
//            if let currentRegion = currentRegion {
//                parent.mapView.setRegion(currentRegion, animated: true)
//            }
            // I removed this. This is centering to user location
        }
        
        func addDriversToMap(_ drivers: [LocationData]) {
//            parent.mapView.removeAnnotations(parent.mapView.annotations)
            let allDriverAnnotations = self.parent.mapView.annotations.filter { annotation in
                if let anno = annotation as? DriverAnnotation {
                    return true
                }
                return false
            }
            
            let allDriverAnnotationsIds = Set(allDriverAnnotations.map { ($0 as! DriverAnnotation).uid })
            let annotationsToRemove = allDriverAnnotations.filter {
                allDriverAnnotationsIds.contains(($0 as! DriverAnnotation).uid)
            }
            
            self.parent.mapView.removeAnnotations(annotationsToRemove)
            
            
            for driver in drivers {
                if driver.id == self.parent.authViewModel.user?.id { continue }
                let annotationsToRemove = self.parent.mapView.annotations.filter { annotation in
                    if let anno = annotation as? DriverAnnotation {
                        return anno.uid == driver.id
                    }
                    return false
                }
                self.parent.mapView.removeAnnotations(annotationsToRemove)
                
                let anno = DriverAnnotation(loc: driver.location, uid: driver.id)
//                anno.subtitle = "driver-\(driver.id)"
//                anno.coordinate = CLLocationCoordinate2D(latitude: driver.location.latitude, longitude: driver.location.longitude)
                self.parent.mapView.addAnnotation(anno)
            }
        }
    }
}