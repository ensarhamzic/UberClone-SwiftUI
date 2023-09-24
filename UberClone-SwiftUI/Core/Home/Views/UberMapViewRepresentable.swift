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
    @ObservedObject var appState = AppState.shared
    @Binding var followingUser: Bool
    @Binding var centerUser: (() -> Void)?
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    @EnvironmentObject var webSocketViewModel: WebSocketViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State var driverPickupPolylineConfigured = false
    @State var driverDropoffPolylineConfigured = false
    
    var locationChosen: (_ coordinate: CLLocationCoordinate2D) -> Void
    
    
    func centerOnUser(context: Context) -> () -> Void {
        
        func innerFunc() -> Void {
            context.coordinator.centerOnUserLocation()
        }
        return innerFunc
            
    }
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        centerUser = self.centerOnUser(context: context)
        
        return mapView
    }

    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        switch appState.mapState {
        case .noInput:
            context.coordinator.clearMapViewAndRecenterOnUserLocation()
            if authViewModel.user?.type == .passenger {
                context.coordinator.addDriversToMap(webSocketViewModel.userLocations)
            }
            DispatchQueue.main.async {
                driverDropoffPolylineConfigured = false
                driverPickupPolylineConfigured = false
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
        case .tripAccepted:
            if authViewModel.user?.type == .passenger {
                context.coordinator.addDriverToMap()
            } else if !driverPickupPolylineConfigured {
                DispatchQueue.main.async {
                    driverPickupPolylineConfigured = true
                }
                let coordinate = CLLocationCoordinate2D(latitude: webSocketViewModel.trip?.pickupLocation.latitude ?? 0, longitude: webSocketViewModel.trip?.pickupLocation.longitude ?? 0)
                
                context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate)
                context.coordinator.configureDriverPolyline(withDestinationCoordinate: coordinate)
            }
        case .tripInProgress:
            if authViewModel.user?.type == .passenger {
                context.coordinator.addDriverToMap()
            } else if authViewModel.user?.type == .driver {
                DispatchQueue.main.async {
                    driverPickupPolylineConfigured = false
                }
                if !driverDropoffPolylineConfigured {
                    DispatchQueue.main.async {
                        driverDropoffPolylineConfigured = true
                    }
                    
                    let coordinate = CLLocationCoordinate2D(latitude: webSocketViewModel.trip?.dropoffLocation.latitude ?? 0, longitude: webSocketViewModel.trip?.dropoffLocation.longitude ?? 0)
                    
                    context.coordinator.clearMapViewAndRecenterOnUserLocation()
                    context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate)
                    context.coordinator.configureDriverPolyline(withDestinationCoordinate: coordinate)
                }
            }
        default:
            break
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}


extension UberMapViewRepresentable {
    
    class MapCoordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        
        
        let parent: UberMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
    
        
        var currentRegion: MKCoordinateRegion?
        
        init(parent: UberMapViewRepresentable) {
            self.parent = parent
            super.init()
            
            let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
            parent.mapView.addGestureRecognizer(tapGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
            panGesture.delegate = self
            parent.mapView.addGestureRecognizer(panGesture)
        
        }
        
        @objc func panGesture (sender: UIPanGestureRecognizer) {
            if !parent.followingUser  { return }
            parent.followingUser = false
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        @objc func handleTap(gestureReconizer: UITapGestureRecognizer) {
            if self.parent.authViewModel.user?.type == .driver {
                return
            }
            
            let location = gestureReconizer.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location,toCoordinateFrom: parent.mapView)
            
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            parent.locationChosen(coordinate)
            

        }
        
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            self.userLocationCoordinate = userLocation.coordinate
            
            // this will cause mapview to constantly center if user is changing location
            //            self.userLocation = userLocation
            
            if !parent.followingUser { return }
            
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            self.currentRegion = region
            

            
            
            
            parent.mapView.setRegion(region, animated: true)
            
        }
        
        func centerOnUserLocation() {
            let region = MKCoordinateRegion(
                center: self.userLocationCoordinate!,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            self.currentRegion = region
            parent.mapView.setRegion(region, animated: true)
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let userLocationCoordinate = self.userLocationCoordinate else {return }
            parent.locationViewModel.getDestinationRoute(from: userLocationCoordinate, to: coordinate) { route in
                self.parent.mapView.addOverlay(route.polyline)
                DispatchQueue.main.async {
                    self.parent.appState.mapState = .polylineAdded
                }
                let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect, edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32))
                
                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        func configureDriverPolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let userLocationCoordinate = self.userLocationCoordinate else {return }
            parent.locationViewModel.getDestinationRoute(from: userLocationCoordinate, to: coordinate) { route in
                self.parent.mapView.addOverlay(route.polyline)
                let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect, edgePadding: .init(top: 70, left: 32, bottom: 500, right: 32))
                
                let region = MKCoordinateRegion(center: userLocationCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                
                self.parent.mapView.setRegion(region, animated: true)
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

                self.parent.mapView.addAnnotation(anno)
            }
        }
        
        func addDriverToMap() {
            if let driverData = self.parent.webSocketViewModel.userLocations.first(where: { $0.id == self.parent.webSocketViewModel.trip!.driverId }) {
                let annotationsToRemove = self.parent.mapView.annotations.filter { annotation in
                    if let anno = annotation as? DriverAnnotation {
                        return anno.uid == driverData.id
                    }
                    return false
                }
                self.parent.mapView.removeAnnotations(annotationsToRemove)
                
                let anno = DriverAnnotation(loc: driverData.location, uid: driverData.id)

                self.parent.mapView.addAnnotation(anno)
            }
            
        }
    }
}
