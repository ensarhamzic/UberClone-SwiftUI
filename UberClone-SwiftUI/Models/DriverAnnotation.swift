//
//  DriverAnnotation.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 27.08.23.
//

import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let uid: String
    
    init(loc: Location, uid: String) {
        self.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        self.uid = uid
    }
    
}
