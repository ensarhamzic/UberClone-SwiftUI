//
//  TripInProgressView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 16.09.23.
//

import SwiftUI
import CoreLocation

struct TripInProgressDriverView: View {
    @ObservedObject var appState = AppState.shared
    @EnvironmentObject var authViewModel: AuthViewModel
    var locationViewModel: LocationSearchViewModel
    @State private var timer: Timer?
    let trip: Trip
    
    @State var timeToArrive: Int? = nil
    @State var distanceToDropoffLocation: Double? = nil
    
    init(locationViewModel: LocationSearchViewModel, trip: Trip) {
        self.locationViewModel = locationViewModel
        self.trip = trip
    }
    
    func configureTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { tmr in
            print("TAJMER SE PALI")
            getRoute()
        
            if appState.mapState != .tripInProgress {
                tmr.invalidate()
                print("Tajmer je zaustavljen.")
            }
        }
    }
    
    
    func getRoute() {
        let fromLocation = LocationManager.shared.userLocation!
        let toLocation = CLLocationCoordinate2D(latitude: trip.dropoffLocation.latitude, longitude: trip.dropoffLocation.longitude)
        
        locationViewModel.getDestinationRoute(from: fromLocation, to: toLocation) { route in
            DispatchQueue.main.async {
                self.timeToArrive = (Int) (route.expectedTravelTime / 60)
                self.distanceToDropoffLocation = route.distance
            }
        }
    }
    
    
    func isDriverInDropoffRegion() -> Bool {
        return (distanceToDropoffLocation ?? 201) <= 200
    }
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            
            VStack {
                HStack {
                    Text("Go to dropoff location")
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
                    let _ = authViewModel.cancelRide(tripId: trip.tripId)
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
                    let _ = authViewModel.completeTrip(tripId: trip.tripId)
                    appState.mapState = .tripCompleted
                } label: {
                    Text("DROPOFF")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 56)
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .disabled(!isDriverInDropoffRegion()) // enable dropoff passenger if driver is in 200m radius to dropoff location
                .opacity(isDriverInDropoffRegion() ? 1 : 0.3)
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
                getRoute()
            }
            configureTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        
        
    }
}

//struct TripInProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        TripInProgressDriverView()
//    }
//}
