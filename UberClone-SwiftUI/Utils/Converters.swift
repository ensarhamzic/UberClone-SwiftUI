//
//  Converters.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 24.08.23.
//

import Foundation

class Converters {
    static func dictionaryToUser(user: [String: Any]) -> User {
        var userType = UserType(rawValue: user["type"] as! Int)
        var carType: RideType? = nil
        
        if user["carType"] != nil {
            carType = RideType(rawValue: user["carType"] as! Int)
        }
        
        return User(
            id: user["_id"] as! String,
            fullName: user["fullName"] as! String,
            email: user["email"] as! String,
            home: dictionaryToLocation(
                location: user["home"] as? [String: Any] ?? nil
            ),
            work: dictionaryToLocation(
                location: user["work"] as? [String: Any] ?? nil
            ),
            type: userType!,
            carType: carType
        )
    }
    
    static func dictionaryToLocation(location: [String: Any]?) -> Location? {
        if location != nil {
            return Location(latitude: location?["latitude"] as! Double, longitude: location?["longitude"] as! Double)
        } else { return nil }
    }
}
