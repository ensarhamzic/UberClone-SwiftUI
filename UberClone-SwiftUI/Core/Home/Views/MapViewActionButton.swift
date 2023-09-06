//
//  MapViewActionButton.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI

struct MapViewActionButton: View {
//    @Binding var state: MapViewState
    @ObservedObject var appState = AppState.shared
    @Binding var showSideMenu: Bool
    @EnvironmentObject var viewModel: LocationSearchViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
//        HStack {
//            Button {
//                withAnimation(.spring()) {
//                    actionForState()
//                }
//            } label: {
//                Image(systemName: imageNameForState(state: state))
//                    .font(.title2)
//                    .foregroundColor(.black)
//                    .padding()
//                    .background(Color.white)
//                    .clipShape((Circle()))
//                    .shadow(color: .black, radius: 5, x: 0, y: 0)
//            }
//            .padding(12)
//            .padding(.top, 32)
//
//            Spacer()
//        }
        Button {
            withAnimation(.spring()) {
                actionForState(appState.mapState)
            }
        } label: {
            Image(systemName: imageNameForState(state: appState.mapState))
                .imageScale(.small)
                .font(.title)
                .foregroundColor(Color.theme.primaryTextColor)
                .padding()
                .background(Color.theme.backgroundColor)
                .clipShape(Circle())
                .shadow(color: .black, radius: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func imageNameForState(state: MapViewState) -> String {
        switch state {
        case .searchingForLocation,
                .locationSelected,
                .tripAccepted,
                .tripRequested,
                .tripCompleted,
                .polylineAdded:
            return "arrow.left"
        case .noInput, .tripCancelled:
            return "line.3.horizontal"
        default:
            return "line.3.horizontal"
        }
    }

//    func actionForState() {
//        switch state {
//        case .noInput:
//            showSideMenu.toggle()
//        case .searchingForLocation:
//            state = .noInput
//        case .locationSelected, .polylineAdded:
//            state = .noInput
//            viewModel.selectedLocation = nil
//        case .tripRequested:
//            state = .noInput
//            viewModel.selectedLocation = nil
//        default: break
//        }
//    }
    
    
    func actionForState(_ state: MapViewState) {
            switch state {
            case .noInput:
                showSideMenu.toggle()
            case .searchingForLocation:
                DispatchQueue.main.async {
                    appState.mapState = .noInput
                }
            case .locationSelected, .polylineAdded:
                DispatchQueue.main.async {
                    appState.mapState = .noInput
                }
                viewModel.selectedUberLocation = nil
            case .tripRequested:
                DispatchQueue.main.async {
                    appState.mapState = .noInput
                }
                viewModel.selectedUberLocation = nil
                let _ = authViewModel.cancelRideRequest()
            default: break
            }
        }
}

struct MapViewActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MapViewActionButton(showSideMenu: .constant(false))
    }
}
