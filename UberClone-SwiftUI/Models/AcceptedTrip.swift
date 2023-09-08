//
//  AcceptedTrip.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 08.09.23.
//

import Foundation

struct AcceptedTrip: Codable, Identifiable {
    let id = NSUUID().uuidString
    let tripId: String
    var passengerName: String
    let dropoffLocationName: String
    let pickupLocation: Location
    let dropoffLocation: Location
    let tripCost: Double
}
