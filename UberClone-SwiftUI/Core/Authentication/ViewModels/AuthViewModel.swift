//
//  AuthViewModel.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 24.08.23.
//

import Foundation
import CoreLocation

class AuthViewModel: ObservableObject {
    @Published var userToken: String?
    @Published var user: User?
    @Published var userLocation: CLLocationCoordinate2D?
    
    init() {
        userToken = UserDefaults.standard.string(forKey: "token")
        
        guard let dt = UserDefaults.standard.data(forKey: "user") else {
            return}
        do {
            let decoder = JSONDecoder()
            let usr = try decoder.decode(User.self, from: dt)
            user = usr
        } catch {
            // Fallback
        }
    }
    
    func registerUser(email: String, fullName: String, password: String, userType: UserType, carType: RideType) -> Any {
        
        var result: Any = ""
        
        // URL zahteva
        guard let url = URL(string: Environments.apiBaseURL + "/users/signup") else {
            return result
        }
        
        // Podaci koje šaljemo
        var params: [String: Any] = ["fullName": fullName, "email": email, "password": password, "userType": userType.id]
        
        if userType == .driver {
            params["carType"] = carType.id
        }
        
        
        // Kreiranje zahteva
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Pretvaranje podataka u JSON format
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("Greška pri pretvaranju u JSON format: \(error)")
            return result
        }
        
        // Slanje zahteva
        let sem = DispatchSemaphore.init(value: 0)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            defer { sem.signal()}
            if let error = error {
                print("Greška pri slanju zahteva: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Obrada odgovora
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                        result = json
                    }
                } catch {
                    print("Greška pri obradi odgovora: \(error)")
                }
            }
        }
        task.resume()
        
        sem.wait()
        return result
    }
    
    func login(email: String, password: String) -> Any {
        
        var result: Any = ""
        
        // URL zahteva
        guard let url = URL(string: Environments.apiBaseURL + "/users/signin") else {
            return result
        }
        
        // Podaci koje šaljemo
        let params: [String: Any] = ["email": email, "password": password]
        
        // Kreiranje zahteva
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Pretvaranje podataka u JSON format
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("Greška pri pretvaranju u JSON format: \(error)")
            return result
        }
        
        // Slanje zahteva
        let sem = DispatchSemaphore.init(value: 0)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            defer { sem.signal()}
            if let error = error {
                print("Greška pri slanju zahteva: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Obrada odgovora
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                        result = json
                    }
                } catch {
                    print("Greška pri obradi odgovora: \(error)")
                }
            }
        }
        task.resume()
        
        sem.wait()
        return result
    }
    
    
    
    func verifyToken(token: String) -> Any {
        var result: Any = ""
        guard let url = URL(string: Environments.apiBaseURL + "/users/verify") else {
            return result
        }
        
        // Kreiranje zahteva
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        // Slanje zahteva
        let session = URLSession.shared
        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: request) { data, response, error in
            defer { sem.signal()}
            if let error = error {
                print("Greška pri slanju zahteva: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Obrada odgovora
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        result = json
                    }
                } catch {
                    print("Greška pri obradi odgovora: \(error)")
                }
            }
        }
        
        task.resume()
        
        
        sem.wait()
        return result
    }
    
    
    
    func authSuccess(token: String?, user: User) {
        
        if(token != nil) {
            UserDefaults.standard.set(token, forKey: "token")
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            UserDefaults.standard.set(data, forKey: "user")
        } catch {
            // Fallback
        }
        
        UserDefaults.standard.synchronize()
        if token != nil {
            userToken = token
        }
        self.user = user
        
        
        print(self.user)
    }
    
    func signOut() -> Void {
        UserDefaults.standard.removeObject(forKey: "token")
        userToken = nil
        user = nil
    }
    
    
    func saveLocation(type: String, latitude: Double, longitude: Double) -> Any {
        var result: Any = ""
        
        // URL zahteva
        guard let url = URL(string: Environments.apiBaseURL + "/users/addLocation") else {
            return result
        }
        
        // Podaci koje šaljemo
        let params: [String: Any] = ["type": type, "latitude": latitude, "longitude": longitude]
        
        // Kreiranje zahteva
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken, forHTTPHeaderField: "Authorization")
        
        // Pretvaranje podataka u JSON format
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("Greška pri pretvaranju u JSON format: \(error)")
            return result
        }
        
        // Slanje zahteva
        let sem = DispatchSemaphore.init(value: 0)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            defer { sem.signal()}
            if let error = error {
                print("Greška pri slanju zahteva: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Obrada odgovora
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                        result = json
                    }
                } catch {
                    print("Greška pri obradi odgovora: \(error)")
                }
            }
        }
        task.resume()
        
        sem.wait()
        return result
    }
    
    func sendRideRequest(pickupLocation: CLLocationCoordinate2D, dropoffLocation: UberLocation, tripCost: Double, rideType: RideType) -> Any {
        var result: Any = ""
        
        // URL zahteva
        guard let url = URL(string: Environments.apiBaseURL + "/users/requestRide") else {
            return result
        }
        
        let pickLocation: [String: Any] = [
            "latitude": pickupLocation.latitude,
            "longitude": pickupLocation.longitude
        ]
        let dropLocation: [String: Any] = [
            "latitude": dropoffLocation.coordinate.latitude,
            "longitude": dropoffLocation.coordinate.longitude
        ]
        let dropoffLocationName = dropoffLocation.title
        // Podaci koje šaljemo
        let params: [String: Any] = [
            "pickupLocation": pickLocation,
            "dropoffLocation": dropLocation,
            "dropoffLocationName": dropoffLocationName,
            "tripCost": tripCost,
            "rideType": rideType.id
        ]
        
        // Kreiranje zahteva
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken, forHTTPHeaderField: "Authorization")
        
        // Pretvaranje podataka u JSON format
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("Greška pri pretvaranju u JSON format: \(error)")
            return result
        }
        
        // Slanje zahteva
        let sem = DispatchSemaphore.init(value: 0)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            defer { sem.signal()}
            if let error = error {
                print("Greška pri slanju zahteva: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Obrada odgovora
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                        result = json
                    }
                } catch {
                    print("Greška pri obradi odgovora: \(error)")
                }
            }
        }
        task.resume()
        
        sem.wait()
        return result
    }
    
    
    func cancelRideRequest() -> Any {
        var result: Any = ""
        
        // URL zahteva
        guard let url = URL(string: Environments.apiBaseURL + "/users/cancelRideRequest") else {
            return result
        }
    
        
        // Podaci koje šaljemo
        // no data
        
        // Kreiranje zahteva
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken, forHTTPHeaderField: "Authorization")
        
        // Slanje zahteva
        let sem = DispatchSemaphore.init(value: 0)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            defer { sem.signal()}
            if let error = error {
                print("Greška pri slanju zahteva: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Obrada odgovora
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                        result = json
                    }
                } catch {
                    print("Greška pri obradi odgovora: \(error)")
                }
            }
        }
        task.resume()
        
        sem.wait()
        return result
    }
    
    func acceptRide(tripId: String) -> Any {
        var result: Any = ""
        
        // URL zahteva
        guard let url = URL(string: Environments.apiBaseURL + "/users/acceptRide") else {
            return result
        }
        
        // Podaci koje šaljemo
        let params: [String: Any] = [
            "tripId": tripId
        ]
        
        // Kreiranje zahteva
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken, forHTTPHeaderField: "Authorization")
        
        // Pretvaranje podataka u JSON format
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("Greška pri pretvaranju u JSON format: \(error)")
            return result
        }
        
        // Slanje zahteva
        let sem = DispatchSemaphore.init(value: 0)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            defer { sem.signal()}
            if let error = error {
                print("Greška pri slanju zahteva: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Obrada odgovora
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                        result = json
                    }
                } catch {
                    print("Greška pri obradi odgovora: \(error)")
                }
            }
        }
        task.resume()
        
        sem.wait()
        return result
    }
}
