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
    @State private var mapState = MapViewState.noInput
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
        if mapState != .noInput { return }
        locationViewModel.selectCustomLocation(title: "Custom", location: coordinate!)
        mapState = .locationSelected
    }
    
    func handleRideRequest(_ rideType: RideType) {
        _ = authViewModel.sendRideRequest(pickupLocation: LocationManager.shared.userLocation!, dropoffLocation: locationViewModel.selectedUberLocation!, tripCost: locationViewModel.computeRidePrice(forType: rideType), rideType: rideType)
        mapState = .tripRequested
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
                UberMapViewRepresentable(mapState: $mapState, followingUser: $followingUser, centerUser: $centerUser, locationChosen: customLocationChosen(_:))
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
                    }
                }
                
                if authViewModel.user?.type == .passenger {
                    if mapState == .searchingForLocation {
                        LocationSearchView(mapState: $mapState)
                    } else if mapState == .noInput {
                        LocationSearchActivationView()
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    mapState = .searchingForLocation
                                }
                            }
                            .shadow(color: .black, radius: 6)
                        
                        HStack {
                            if authViewModel.user?.home != nil {
                                LocationShortcutView(imageName: "house", title: "Home")
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            locationViewModel.selectSavedLocation(title: "Home", location: authViewModel.user?.home)
                                            mapState = .locationSelected
                                        }
                                    }
                            }
                            if authViewModel.user?.work != nil {
                                LocationShortcutView(imageName: "archivebox", title: "Work")
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            locationViewModel.selectSavedLocation(title: "Work", location: authViewModel.user?.work)
                                            mapState = .locationSelected
                                        }
                                    }
                            }
                            
                        }
                        .padding(.top, 70)
                    }
                }
                
                MapViewActionButton(mapState: $mapState, showSideMenu: $showSideMenu)
                    .padding(.leading)
                    .padding(.top, 4)
            }
            
            if mapState == .locationSelected || mapState == .polylineAdded {
                RideRequestView(rideRequestHandler: handleRideRequest)
                    .transition(.move(edge: .bottom))
            }
            
            if let trip = webSocketViewModel.trip {
                AcceptTripView(route: $routeToPassenger, wsViewModel: webSocketViewModel)
                    .transition(.move(edge: .bottom))
            }
            
            if mapState == .tripRequested {
                TripLoadingView()
                    .transition(.move(edge: .bottom))
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
