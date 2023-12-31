//
//  HomeView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI
import CoreLocation
import MapKit

struct HomeView: View {
    @ObservedObject var appState = AppState.shared
    @State private var showSideMenu = false
    @State private var timer: Timer?
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var webSocketViewModel: WebSocketViewModel
    
    @State private var centerUser: (() -> Void)?
    @State private var followingUser: Bool = true
    
    @State var routeToPassenger: MKRoute?
    
    
    var body: some View {
        Group {
            if authViewModel.userToken == nil {
                LoginView()
            } else if let user = authViewModel.user {
                NavigationStack {
                    ZStack {
                        if showSideMenu {
                            SideMenuView()
                        }
                        mapView
                            .offset(x: showSideMenu ? 316 : 0)
                            .shadow(color: showSideMenu ? .black : .clear, radius: 10)
                    }
                    .onAppear {
                        showSideMenu = false
                    }
                }
                .onAppear {
                    webSocketViewModel.connect(userId: user.id, userType: user.type, carType: user.carType?.id)
                }
                
            }
        }
    }
    
    func customLocationChosen(_ coordinate: CLLocationCoordinate2D?) {
        if appState.mapState != .noInput { return }
        locationViewModel.selectCustomLocation(title: "Custom", location: coordinate!)
        
        DispatchQueue.main.async {
            appState.mapState = .locationSelected
        }
    }
    
    func handleRideRequest(_ rideType: RideType) {
        _ = authViewModel.sendRideRequest(pickupLocation: LocationManager.shared.userLocation!, dropoffLocation: locationViewModel.selectedUberLocation!, tripCost: locationViewModel.computeRidePrice(forType: rideType), rideType: rideType)
        DispatchQueue.main.async {
            appState.mapState = .tripRequested
        }
    }
    
    func getDriverToPassengerRoute(trip: Trip) -> MKRoute? {
        var routeToPass: MKRoute?
        print("getting route")
        
        let fromLocation = LocationManager.shared.userLocation!
        let toLocation = CLLocationCoordinate2D(latitude: trip.pickupLocation.latitude, longitude: trip.pickupLocation.longitude)
        
        locationViewModel.getDestinationRoute(from: fromLocation, to: toLocation) { route in
            print("Expected travel time \(route.expectedTravelTime / 60)")
            print("Distance from pass \(route.distance / 1000)")
            routeToPass = route
            self.routeToPassenger = route
        }
        return routeToPass
    }
    
    
}


extension HomeView {
    var mapView: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                UberMapViewRepresentable(followingUser: $followingUser, centerUser: $centerUser, locationChosen: customLocationChosen(_:))
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            followingUser = true
                            centerUser!()
                        } label: {
                            Image(systemName: "location.north.circle")
                                .resizable()
                                .frame(width: 55, height: 55)
                                .font(.title)
                                .foregroundColor(Color.theme.primaryTextColor)
                                .background(Color.theme.backgroundColor)
                                .clipShape(Circle())
                                .shadow(color: .black, radius: 6)
                        }
                        .padding()
                        .opacity(followingUser ? 0.3 : 1)
                        .disabled(followingUser)
                        .padding(.bottom, (appState.mapState == .tripAccepted || appState.mapState == .tripInProgress) ? 375 : 0)
                    }
                }
                
                if authViewModel.user?.type == .passenger {
                    if appState.mapState == .searchingForLocation {
                        LocationSearchView()
                    } else if appState.mapState == .noInput {
                        LocationSearchActivationView()
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    DispatchQueue.main.async {
                                        appState.mapState = .searchingForLocation
                                    }
                                }
                            }
                            .shadow(color: .black, radius: 6)
                        
                        HStack {
                            if authViewModel.user?.home != nil {
                                LocationShortcutView(imageName: "house", title: "Home")
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            locationViewModel.selectSavedLocation(title: "Home", location: authViewModel.user?.home)
                                            DispatchQueue.main.async {
                                                appState.mapState = .locationSelected
                                            }
                                            
                                        }
                                    }
                            }
                            if authViewModel.user?.work != nil {
                                LocationShortcutView(imageName: "archivebox", title: "Work")
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            locationViewModel.selectSavedLocation(title: "Work", location: authViewModel.user?.work)
                                            DispatchQueue.main.async {
                                                appState.mapState = .locationSelected
                                            }
                                        }
                                    }
                            }
                            
                        }
                        .padding(.top, 70)
                    }
                }
                
                MapViewActionButton(showSideMenu: $showSideMenu)
                    .padding(.leading)
                    .padding(.top, 4)
            }
            
            if appState.mapState == .locationSelected || appState.mapState == .polylineAdded {
                RideRequestView(rideRequestHandler: handleRideRequest)
                    .transition(.move(edge: .bottom))
            }
            
            if appState.mapState == .tripRequested && authViewModel.user?.type == .driver {
                if let trip = webSocketViewModel.trip {
                        AcceptTripView(route: $routeToPassenger, wsViewModel: webSocketViewModel, authViewModel: authViewModel)
                            .transition(.move(edge: .bottom))
                }
            }
            
            
            if appState.mapState == .tripRequested && authViewModel.user?.type == .passenger {
                TripLoadingView()
                    .transition(.move(edge: .bottom))
            }
            
            if appState.mapState == .tripAccepted && authViewModel.user?.type == .passenger {
                if let trip = webSocketViewModel.trip {
                    TripAcceptedView(trip: trip, webSocketViewModel: webSocketViewModel, locationViewModel: locationViewModel)
                        .transition(.move(edge: .bottom))
                }
            }
            
            if appState.mapState == .tripAccepted && authViewModel.user?.type == .driver {
                if let trip = webSocketViewModel.trip {
                    PickupPassengerView(trip: trip, webSocketViewModel: webSocketViewModel, locationViewModel: locationViewModel)
                        .transition(.move(edge: .bottom))
                }
            }
            
            if appState.mapState == .tripCancelled {
                TripCancelledView()
            }
            
            if appState.mapState == .tripInProgress {
                if authViewModel.user?.type == .driver {
                    TripInProgressDriverView(locationViewModel: locationViewModel, trip: webSocketViewModel.trip!)
                } else {
                    TripInProgressPassengerView(locationViewModel: locationViewModel, trip: webSocketViewModel.trip!)
                }
            }
            
            if appState.mapState == .tripCompleted {
                TripCompletedView(trip: webSocketViewModel.trip!)
            }
            
            if appState.mapState == .driverRewarded {
                DriverRewardedView(reward: webSocketViewModel.reward!)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onReceive(LocationManager.shared.$userLocation) { location in
            if let location = location {
                if locationViewModel.userLocation?.latitude != location.latitude || locationViewModel.userLocation?.longitude != location.longitude {
                    locationViewModel.userLocation = location
                }
                authViewModel.userLocation = location
            }
        }
        .onReceive(webSocketViewModel.$trip, perform: { newTrip in
            if newTrip != nil {
                getDriverToPassengerRoute(trip: newTrip!)
            }
        })
        .onAppear {
            // Create a repeating timer that fires every 5 seconds
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
                // Code to be executed every 5 seconds
                if authViewModel.userLocation != nil && authViewModel.userToken != nil && authViewModel.user?.type == .driver {
                    webSocketViewModel.sendLocationMessage(userId: authViewModel.user!.id, location: authViewModel.userLocation!)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}


//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
