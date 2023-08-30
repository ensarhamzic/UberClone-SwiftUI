//
//  UserType.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 29.08.23.
//

import Foundation

enum UserType: Int, CaseIterable, Identifiable, Codable {
    case passenger
    case driver
    
    var id: Int { return rawValue }
    
    
    var name: String {
        switch self {
        case .passenger: return "passenger"
        case .driver: return "driver"
        }
    }
}
