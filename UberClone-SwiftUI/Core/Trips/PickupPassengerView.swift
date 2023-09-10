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
    
    @State var timeToArrive: Int = 0
    
    func getDriverToPassengerRoute() {
        let fromLocation = LocationManager.shared.userLocation!
        let toLocation = CLLocationCoordinate2D(latitude: trip.pickupLocation.latitude, longitude: trip.pickupLocation.longitude)
        
        locationViewModel.getDestinationRoute(from: fromLocation, to: toLocation) { route in
            print("KALKULISE SE")
            DispatchQueue.main.async {
                self.timeToArrive = (Int) (route.expectedTravelTime / 60)
            }
        }
    }
    
    init(trip: Trip, webSocketViewModel: WebSocketViewModel, locationViewModel: LocationSearchViewModel) {
        print("INICIJALIZACIJA")
        print("")
        print("")
        
        self.trip = trip
        self.webSocketViewModel = webSocketViewModel
        self.locationViewModel = locationViewModel
    }
    
    func configureTimer() {
//        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { tmr in
//
//            getDriverToPassengerRoute()
//
//            if appState.mapState != .tripAccepted {
//                    tmr.invalidate()
//                print("Tajmer je zaustavljen.")
//            }
//        }
        
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
                        Text("\(timeToArrive)")
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.passengerName ?? "")
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(.systemYellow))
                                .imageScale(.small)
                            
                            Text("4.8")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    
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
            
            Button {
                let _ = authViewModel.cancelRide(tripId: webSocketViewModel.trip?.tripId ?? "")
            } label: {
                Text("CANCEL RIDE")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 25)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secondaryBackgroundColor, radius: 20)
//        .onReceive(webSocketViewModel.$userLocations) { userLocations in
//            getPassengerToDriverTime()
//        }
        .onAppear {
            if timeToArrive == 0 {
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
