//
//  WebSocketViewModel.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 27.08.23.
//

import SwiftUI
import CoreLocation

struct DecodableData: Codable {
    let type: String
    let data: String
}

struct LocationMessage: Codable {
    let type: String
    let location: Location
    let id: String
}

struct OfflineMessage: Codable {
    let type: String
    let userId: String
}

struct LocationData: Codable, Identifiable {
    let id: String
    let location: Location
}

struct OfflineData: Codable {
    let userId: String
}


class WebSocketViewModel: ObservableObject {
    @Published var userLocations: [LocationData] = []
    @Published var trip: Trip? = nil
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    func connect(userType: UserType, carType: Int?) {
        var urlString = "\(Environments.webSocketURL)?type=\(userType)"
        if carType != nil {
            urlString = urlString + "&carType=\(carType!)"
        }
        
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        
        webSocketTask?.resume()
        receiveMessage()
        
        
        
        //        webSocketTask?.resume()
    }
    
    
    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let jsonString):
//                    print(jsonString)
                    let jsonData = jsonString.data(using: .utf8)
                    
                    do {
                        let decodedMessage = try JSONDecoder().decode(DecodableData.self, from: jsonData!)
                        switch decodedMessage.type {
                        case "location":
                            let dataToDecode = decodedMessage.data.data(using: .utf8)
                            let decodedData = try JSONDecoder().decode(LocationData.self, from: dataToDecode!)
                            if let existingIndex = self.userLocations.firstIndex(where: { $0.id == decodedData.id }) {
                                // Update the existing element
                                DispatchQueue.main.async {
                                    self.userLocations[existingIndex] = decodedData
                                }
                            } else {
                                // Append the new element
                                DispatchQueue.main.async {
                                    self.userLocations.append(decodedData)
                                }
                                
                            }
                            print("Decoded Data:", decodedData)
                        case "offline":
                            let dataToDecode = decodedMessage.data.data(using: .utf8)
                            let decodedData = try JSONDecoder().decode(OfflineData.self, from: dataToDecode!)
                            DispatchQueue.main.async {
                                self.userLocations = self.userLocations.filter { userLocation in
                                    if userLocation.id == decodedData.userId {
                                        return false
                                    }
                                    return true
                                }
                            }
                        case "rideRequest":
                            let dataToDecode = decodedMessage.data.data(using: .utf8)
                            let decodedData = try JSONDecoder().decode(Trip.self, from: dataToDecode!)
                            DispatchQueue.main.async {
                                print(decodedData)
                                self.trip = decodedData
                            }
                        default:
                            break
                        }
                        
                        
                    } catch {
                        print("Error decoding JSON:", error)
                    }
                    break
                case .data(let data):
                    print(data)
                    
                    break
                default:
                    break
                }
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
            self.receiveMessage()
        }
    }
    
    func sendLocationMessage(userId: String, location: CLLocationCoordinate2D) {
        let loc = Location(latitude: location.latitude, longitude: location.longitude)
        let message = LocationMessage(type: "location", location: loc, id: userId)
        sendMessage(content: message)
    }
    
    func sendOfflineMessage(userId: String) {
        let message = OfflineMessage(type: "offline", userId: userId)
        sendMessage(content: message)
    }
    
    private func sendMessage(content: Encodable) {
        if let jsonData = try? JSONEncoder().encode(content),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webSocketTask?.send(.string(jsonString), completionHandler: { error in
                if let error = error {
                    print("Sending message error: \(error)")
                }
            })
        }
    }
    
    
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        // Set webSocketTask to nil or perform any other cleanup as needed
    }

}
