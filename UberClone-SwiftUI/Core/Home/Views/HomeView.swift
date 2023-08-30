//
//  HomeView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @State private var mapState = MapViewState.noInput
    @State private var showSideMenu = false
    @State private var timer: Timer?
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var webSocketViewModel: WebSocketViewModel
    
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
                    webSocketViewModel.connect(userType: user.type, carType: user.carType)
                }
                
            }
        }
    }
    
    func customLocationChosen(_ coordinate: CLLocationCoordinate2D?) {
        if mapState != .noInput { return }
        locationViewModel.selectCustomLocation(title: "Custom", location: coordinate!)
        mapState = .locationSelected
    }
}


extension HomeView {
    var mapView: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                UberMapViewRepresentable(mapState: $mapState, locationChosen: customLocationChosen(_:))
                    .ignoresSafeArea()
                
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
                RideRequestView()
                    .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onReceive(LocationManager.shared.$userLocation) { location in
            if let location = location {
                if locationViewModel.userLocation == nil {
                    locationViewModel.userLocation = location
                }
                authViewModel.userLocation = location
            }
        }
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


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
