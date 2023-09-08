//
//  UberClone_SwiftUIApp.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI

@main
struct UberClone_SwiftUIApp: App {
    @StateObject var locationViewModel = LocationSearchViewModel()
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var webSocketViewModel = WebSocketViewModel()
    
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        let token = UserDefaults.standard.string(forKey: "token")
        if(token == nil) { return }
        
        let result = authViewModel.verifyToken(token: token!) as! [String: Any]
        if result["success"] is String {
            let user = result["user"] as! [String: Any]
            let loggedInUser = Converters.dictionaryToUser(user: user)
            authViewModel.authSuccess(token: token!, user: loggedInUser)
        } else {
            if authViewModel.user?.type == .driver {
                webSocketViewModel.sendOfflineMessage(userId: authViewModel.user!.id)
            }
            authViewModel.signOut()
        }
    
    }
    
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationViewModel)
                .environmentObject(authViewModel)
                .environmentObject(webSocketViewModel)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .active {
                print("Active")
            } else if newPhase == .background {
                if authViewModel.user?.type == .driver {
                    webSocketViewModel.sendOfflineMessage(userId: authViewModel.user!.id)
                }
            }
        }
    }
}





