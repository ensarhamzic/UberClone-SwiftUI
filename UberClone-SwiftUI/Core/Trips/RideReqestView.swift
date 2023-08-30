//
//  RideReqestView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI
import MapKit

struct RideRequestView: View {
//    @EnvironmentObject var viewModel: HomeViewModel
    @State var selectedRideType: RideType = .uberX
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    
    var body: some View {
//        VStack {
//            Capsule()
//                .foregroundColor(Color(.systemGray5))
//                .frame(width: 48, height: 6)
//                .padding(8)
//
//            VStack(alignment: .leading, spacing: 24) {
//                TripLocationsView()
//                    .padding(.horizontal)
//
//                Divider()
//
//                Text("SUGGESTED RIDES")
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .padding(.leading)
//                    .foregroundColor(Color(.darkGray))
//
//                rideTypeView
//
//                paymentTypeView
//            }
//
//            Button {
//                viewModel.requestRide(selectedRideType)
//            } label: {
//                Text("CONFIRM RIDE")
//                    .fontWeight(.bold)
//                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
//                    .background(Color(.systemBlue))
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
//            }
//
//            Spacer()
//        }
//        .background(Color.theme.backgroundColor)
//        .frame(height: 516)
//        .clipShape(RoundedShape(corners: [.topLeft, .topRight]))
//        .shadow(color: .black, radius: 10, x: 0, y: 0)
        
        VStack {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            
            HStack {
                VStack {
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                    
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(width: 1, height: 32)
                    
                    Circle()
                        .fill(.black)
                        .frame(width: 8, height: 8)
                }
                
                VStack(alignment: .leading, spacing: 35) {
                    HStack {
                        Text("Current location")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(locationViewModel.pickupTime ?? "")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        if let location = locationViewModel.selectedUberLocation {
                            Text(location.title)
                                .font(.system(size: 16, weight: .semibold))
                        }
                       
                        
                        Spacer()
                        
                        Text(locationViewModel.dropOffTime ?? "")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 8)
            }
            .padding()
            
            
            Divider()
            
            Text("SUGGESTED RIDES")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(RideType.allCases) { type in
                        VStack(alignment: .leading) {
                            Image(type.imageName)
                                .resizable()
                                .scaledToFit()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(type.description)
                                    .font(.system(size: 14, weight: .semibold))
                                
                                Text(locationViewModel.computeRidePrice(forType: type).toCurrency())
                                    .font(.system(size: 14, weight:.semibold))
                            }
                            .padding()
                        }
                        .frame(width: 112, height: 140)
                        .foregroundColor(type == selectedRideType ? .white : Color.theme.primaryTextColor)
                        .background(type == selectedRideType ? .blue : Color.theme.secondaryBackgroundColor)
                        .scaleEffect(type == selectedRideType ? 1.2 : 1.0)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedRideType = type
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            
            Divider()
                .padding(.vertical, 8)
            
            
            HStack(spacing: 12) {
                Text("Visa")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(6)
                    .background(.blue)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .padding(.leading)
                
                Text("**** 1234")
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .imageScale(.medium)
                    .padding()
            }
            .frame(height: 50)
            .background(Color.theme.secondaryBackgroundColor)
            .cornerRadius(10)
            .padding(.horizontal)
            
            
            Button {
                
            } label: {
                Text("CONFIRM RIDE")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 24)
        .background(Color.theme.backgroundColor)
        .cornerRadius(20)
    }
}

struct RideRequestView_Previews: PreviewProvider {
    static var previews: some View {
        RideRequestView()
    }
}

//extension RideRequestView {
//    var rideTypeView: some View {
//
//        ScrollView(.horizontal) {
//            HStack(spacing: 12) {
//                ForEach(RideType.allCases, id: \.self) { rideType in
//                    VStack(alignment: .leading) {
//                        Image(rideType.imageName)
//                            .resizable()
//                            .scaledToFit()
//
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(rideType.description)
//                                .font(.system(size: 14, weight: .semibold))
//
//                            Text(viewModel.ridePriceForType(rideType).toCurrency())
//                                .font(.system(size: 14, weight: .semibold))
//                        }
//                        .foregroundColor(rideType == selectedRideType ? .white : Color.theme.primaryTextColor)
//                        .padding(.vertical, 8)
//                        .padding(.leading)
//                    }
//                    .frame(width: 112, height: 140)
//                    .background(rideType == selectedRideType ? Color(.systemBlue) : Color.theme.secondaryBackgroundColor)
//                    .scaleEffect(selectedRideType == rideType ? 1.2 : 1.0)
//                    .cornerRadius(10)
//                    .onTapGesture {
//                        withAnimation(.spring()) {
//                            selectedRideType = rideType
//                        }
//                    }
//                }
//            }
//        }
//        .padding(.horizontal)
//    }
//
//    var paymentTypeView: some View {
//        HStack(spacing: 12) {
//            Text("Visa")
//                .font(.subheadline)
//                .fontWeight(.semibold)
//                .padding(5)
//                .background(Color(.systemBlue))
//                .cornerRadius(4)
//                .foregroundColor(.white)
//                .padding(.leading)
//
//            Text("**** 1234")
//                .fontWeight(.bold)
//
//            Spacer()
//
//            Image(systemName: "chevron.right")
//                .imageScale(.medium)
//                .padding()
//        }
//        .frame(height: 50)
//        .background(Color.theme.secondaryBackgroundColor)
//        .cornerRadius(10)
//        .padding(.horizontal)
//        .padding(.bottom, 8)
//    }
//}
