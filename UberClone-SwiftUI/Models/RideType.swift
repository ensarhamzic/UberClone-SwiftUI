//
//  RideType.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import Foundation

enum RideType: Int, CaseIterable, Identifiable, Codable {
    case uberX
    case black
    case uberXL
    
    var id: Int { return rawValue }
    
    var currentGasPricePerGallon: Double { return 4.3 }
    
    var description: String {
        switch self {
        case .uberX:return "UberX"
        case .black:return "Uber Black"
        case .uberXL:return "UberXL"
        }
    }
    
    var imageName: String {
        switch self {
        case .uberX: return "uber-x"
        case .black: return "uber-black"
        case .uberXL: return "uber-x"
        }
    }
    
    var baseFare: Double {
        switch self {
        case .uberX: return 2
        case .black: return 10
        case .uberXL: return 5
        }
    }
    
    func computePrice(for distanceInMeters: Double) -> Double {
        let distanceInKilometers = distanceInMeters / 1000
        
        print(distanceInKilometers)
        
        switch self {
        case .uberX: return distanceInKilometers * 1.2 + baseFare
        case .black: return distanceInKilometers * 1.5 + baseFare
        case .uberXL: return distanceInKilometers * 1.75 + baseFare
        }
    }
}
