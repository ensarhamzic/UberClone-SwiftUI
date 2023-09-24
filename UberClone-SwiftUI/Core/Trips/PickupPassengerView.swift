//
//  PickupPassengerView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 08.09.23.
//

import SwiftUI
import CoreLocation

struct PickupPassengerView: View {
    let appState = AppState.shared
    @State private var timer: Timer?
    
    let trip: Trip
    var webSocketViewModel: WebSocketViewModel
    var locationViewModel: LocationSearchViewModel

    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State var timeToArrive: Int? = nil
    @State var distanceToPassenger: Double? = nil
    
    func getDriverToPassengerRoute() {
        let fromLocation = LocationManager.shared.userLocation!
        let toLocation = CLLocationCoordinate2D(latitude: trip.pickupLocation.latitude, longitude: trip.pickupLocation.longitude)
        
        locationViewModel.getDestinationRoute(from: fromLocation, to: toLocation) { route in
            DispatchQueue.main.async {
                self.timeToArrive = (Int) (route.expectedTravelTime / 60)
                self.distanceToPassenger = route.distance
                print("Distance is \(distanceToPassenger ?? 0) meters")
            }
        }
    }
    
    func isDriverInPassengerRegion() -> Bool {
        return (distanceToPassenger ?? 201) <= 200
    }
    
    init(trip: Trip, webSocketViewModel: WebSocketViewModel, locationViewModel: LocationSearchViewModel) {
        self.trip = trip
        self.webSocketViewModel = webSocketViewModel
        self.locationViewModel = locationViewModel
    }
    
    func configureTimer() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { tmr in
            print("TAJMER SE PALI")
            getDriverToPassengerRoute()
        
            if appState.mapState != .tripAccepted {
                tmr.invalidate()
                print("Tajmer je zaustavljen.")
            }
        }

    
    }
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            VStack {
                HStack {
                    Text("Go to pickup location")
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 44)
                    
                    Spacer()
                    
                    VStack {
                        Text("\(timeToArrive ?? 0)")
                            .bold()
                        
                        Text("min")
                            .bold()
                    }
                    .frame(width: 56, height: 56)
                    .foregroundColor(.white)
                    .background(Color(.systemBlue))
                    .cornerRadius(10)
                }
                .padding()
                
                Divider()
            }
            
            
            VStack {
                HStack {
                    Image("male-profile-photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    
                    Text(trip.passengerName ?? "")
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Text("Earnings")
                        
                        Text(trip.tripCost.toCurrency())
                            .font(.system(size: 24, weight: .semibold))
                    }
                }
                
                Divider()
            }
            .padding()
            
            HStack {
                Button {
                    let _ = authViewModel.cancelRide(tripId: webSocketViewModel.trip?.tripId ?? "")
                } label: {
                    Text("CANCEL RIDE")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 56)
                        .background(Color(.systemRed))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button {
                    let _ = authViewModel.pickupPassenger(tripId: webSocketViewModel.trip?.tripId ?? "")
                    appState.mapState = .tripInProgress
                } label: {
                    Text("PICKUP")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 56)
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .disabled(!isDriverInPassengerRegion()) // enable pickup passenger if driver is in 200m radius to passenger
                .opacity(isDriverInPassengerRegion() ? 1 : 0.3)
            }
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom, 25)
        
        }
        .padding(.bottom, 25)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secondaryBackgroundColor, radius: 20)
        .onAppear {
            if timeToArrive == nil {
                getDriverToPassengerRoute()
            }
            configureTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

//struct PickupPassengerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PickupPassengerView()
//    }
//}
