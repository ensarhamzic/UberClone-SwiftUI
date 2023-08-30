//
//  SideMenuView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 24.08.23.
//

import SwiftUI

struct SideMenuView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 32) {
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
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Do more with your account")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "dollarsign.square")
                                .font(.title2)
                                .imageScale(.medium)
                            
                            Text("Make money driving")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(6)
                        }
                    }
                    
                    Rectangle()
                        .frame(width: 300, height: 0.75)
                        .opacity(0.7)
                        .foregroundColor(Color(.separator))
                        .shadow(color: .black.opacity(0.7), radius: 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                
                
                
                VStack {
                    ForEach(SideMenuOptionViewModel.allCases) { viewModel in
                        NavigationLink(value: viewModel) {
                            SideMenuOptionView(viewModel: viewModel)
                                .padding()
                        }
                    }
                }
                .navigationDestination(for: SideMenuOptionViewModel.self) { viewModel in
                    switch viewModel {
                    case .trips:
                        Text("trips")
                    case .wallet:
                        Text("wallet")
                    case .settings:
                        SettingsView()
                    case .messages:
                        Text("messages")
                    }
                }
                
                Spacer()
                
            }
            .padding(.top, 32)
            .background(Color.theme.backgroundColor)
        
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SideMenuView()
        }
    }
}

