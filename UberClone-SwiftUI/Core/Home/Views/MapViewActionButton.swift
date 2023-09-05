//
//  MapViewActionButton.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI

struct MapViewActionButton: View {
//    @Binding var state: MapViewState
    @Binding var mapState: MapViewState
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
                actionForState(mapState)
            }
        } label: {
            Image(systemName: imageNameForState(state: mapState))
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
                mapState = .noInput
            case .locationSelected, .polylineAdded:
                mapState = .noInput
                viewModel.selectedUberLocation = nil
            case .tripRequested:
                mapState = .noInput
                viewModel.selectedUberLocation = nil
                let _ = authViewModel.cancelRideRequest()
            default: break
            }
        }
}

struct MapViewActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MapViewActionButton(mapState: .constant(.noInput), showSideMenu: .constant(false))
    }
}
