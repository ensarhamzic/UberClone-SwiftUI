//
//  SettingsView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 26.08.23.
//

import SwiftUI
import MapKit

struct SettingsView: View {
    @EnvironmentObject var webSocketViewModel: WebSocketViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            List{
                Section {
                    HStack {
                        Image("male-profile-photo")
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 64, height: 64)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(authViewModel.user?.fullName ?? "")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text(authViewModel.user?.email ?? "")
                                .accentColor(Color.theme.primaryTextColor)
                                .opacity(0.77)
                                .font(.system(size: 14))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(8)
                }
                
                Section ("Favorites"){
                    NavigationLink {
                        SaveLocationMapView(buttonClicked: {
                            coordinate in
                            saveLocation(coordinate, type: "home")
                        }, savedCoordinate: authViewModel.user?.home)
                    } label: {
                        SettingsRowView(imageName: "house.circle.fill", title: "Home location", tintColor: Color(.systemBlue))
                    }
                    
                    NavigationLink {
                        SaveLocationMapView(buttonClicked: {
                            coordinate in
                            saveLocation(coordinate, type: "work")
                        }, savedCoordinate: authViewModel.user?.work)
                    } label: {
                        SettingsRowView(imageName: "archivebox.circle.fill", title: "Work location", tintColor: Color(.systemBlue))
                    }
                }
                
                Section("Settings") {
                    SettingsRowView(imageName: "bell.circle.fill", title: "Notifications", tintColor: Color(.systemPurple))
                    
                    SettingsRowView(imageName: "creditcard.circle.fill", title: "Payment Methods", tintColor: Color(.systemBlue))
                }
                
                Section("Account") {
                    SettingsRowView(imageName: "dollarsign.circle.fill", title: "Make Money Driving", tintColor: Color(.systemGreen))
                    
                    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: Color(.systemRed))
                        .onTapGesture {
                            webSocketViewModel.disconnect()
                            authViewModel.signOut()
                        }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    func saveLocation(_ coordinate: CLLocationCoordinate2D?, type: String) -> Void {
        let location = coordinate!
        let result = authViewModel.saveLocation(type: type, latitude: location.latitude, longitude: location.longitude) as! [String: Any]
        if let user = result["user"] as? [String: Any] {
            let updatedUser = Converters.dictionaryToUser(user: user)
            authViewModel.authSuccess(token: nil, user: updatedUser)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
