//
//  Trip.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 31.08.23.
//

import Foundation

struct Trip: Codable, Identifiable, Equatable {
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.tripId == rhs.tripId
    }
    
    let id = NSUUID().uuidString
    let tripId: String
    var passengerId: String?
    var passengerName: String?
    let dropoffLocationName: String?
    let pickupLocation: Location
    let dropoffLocation: Location
    let tripCost: Double
    let driverId: String?
    let driverName: String?
    let rideType: RideType?
}
