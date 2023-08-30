//
//  MapViewState.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import Foundation

enum MapViewState: Int {
    case noInput
    case searchingForLocation
    case locationSelected
    case tripRequested
    case tripAccepted
    case driverArrived
    case tripInProgress
    case arrivedAtDestination
    case tripCompleted
    case tripCancelled
    case polylineAdded
}
