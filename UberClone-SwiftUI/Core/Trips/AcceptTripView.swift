//
//  AcceptTripView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 31.08.23.
//

import SwiftUI
import MapKit

struct AcceptTripView: View {
    let webSocketViewModel: WebSocketViewModel
    let authViewModel: AuthViewModel
    
    @State private var region: MKCoordinateRegion
//    let route: MKRoute
    @State private var annotationItem: UberLocation
    
    @Binding var route: MKRoute?
    
    @ObservedObject var appState = AppState.shared
    
    init(route: Binding<MKRoute?>, wsViewModel: WebSocketViewModel, authViewModel: AuthViewModel) {
        _route = route
        self.region = MKCoordinateRegion()
        self.webSocketViewModel = wsViewModel
        self.authViewModel = authViewModel
        let center = CLLocationCoordinate2D(latitude: webSocketViewModel.trip!.pickupLocation.latitude, longitude: webSocketViewModel.trip!.pickupLocation.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        self.region = MKCoordinateRegion(center: center, span: span)
        self.annotationItem = UberLocation(title: "", coordinate: center)
    }
    
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            VStack {
                HStack {
                    Text("Would you like to pick up this passenger?")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 44)
                    
                    Spacer()
                    
                    VStack {
                        Text(route != nil ? String(Int(route!.expectedTravelTime / 60)) : "0")
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
                        Text(webSocketViewModel.trip?.passengerName ?? "")
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
                        
                        Text(webSocketViewModel.trip?.tripCost.toCurrency() ?? "$0.00")
                            .font(.system(size: 24, weight: .semibold))
                    }
                }
                
                Divider()
            }
            .padding()
            
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Apple campus")
                            .font(.headline)
                        
                        Text("Infinite loop 1, Ssanta Clara Country")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text(route != nil ? route!.distance.distanceInKilometersString() : "0.00")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("km")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                Map(coordinateRegion: $region, annotationItems: [annotationItem]) { item in
                    MapMarker(coordinate: item.coordinate)
                }
                    .frame(height: 220)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.6), radius: 10)
                    .padding()
                
                
                Divider()
                
            }
            
            HStack {
                Button {
                    route = nil
                    webSocketViewModel.trip = nil
                } label: {
                    Text("Reject")
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
                    guard let tripId = webSocketViewModel.trip?.tripId else { return }
                    let _ = authViewModel.acceptRide(tripId: tripId)
                } label: {
                    Text("Accept")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 56)
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom, 25)
        }
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secondaryBackgroundColor, radius: 20)
    }
}
//
//struct AcceptTripView_Previews: PreviewProvider {
//    static var previews: some View {
//        AcceptTripView(trip: Trip(id: "1", passengerName: "ENSAR", dropoffLocationName: "Hotel Vrbak", pickupLocation: Location(latitude: 20, longitude: 20), dropoffLocation: Location(latitude: 20.1, longitude: 20.1), tripCost: 22), route: <#MKRoute#>)
//    }
//}
