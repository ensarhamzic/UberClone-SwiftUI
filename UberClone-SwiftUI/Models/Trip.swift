//
//  Trip.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 31.08.23.
//

import Foundation

struct Trip: Identifiable, Codable {
    let id: String
    
    let passengerId: String
    let driverId: String
    let passengerName: String
    let driverName: String
    
    let pickupLocationName: String
    let dropoffLocationName: String
    let pickupLocationAddress: String // ne treba mi ja msm
    
    let pickupLocation: Location
    let dropoffLocation: Location
    
    let tripCost: Double
}
