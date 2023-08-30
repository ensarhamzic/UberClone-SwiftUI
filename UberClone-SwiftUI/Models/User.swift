//
//  User.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 24.08.23.
//

import Foundation

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

struct User: Codable {
    var id: String
    var fullName: String
    var email: String
    var home: Location?
    var work: Location?
    var type: UserType
    var carType: RideType?
}
