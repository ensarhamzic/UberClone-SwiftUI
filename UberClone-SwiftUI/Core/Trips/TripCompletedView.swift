//
//  TripCompletedView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 16.09.23.
//

import SwiftUI

struct TripCompletedView: View {
    @ObservedObject var appState = AppState.shared
    @EnvironmentObject var authViewModel: AuthViewModel
    var trip: Trip
    
    @State var tipPercent = 0
    @State var tipValue = 0.0
    @State var rating = 0
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            Text("This trip has been completed")
                .padding(.vertical)
            
            if authViewModel.user?.type == .passenger {
                Text("Tip: \(tipValue.toCurrency())")
                Text("Trip cost: \((trip.tripCost + tipValue).toCurrency())")
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("0%")
                            .font(.system(size: 17, weight: .semibold))
                        
                        
                            .padding()
                    }
                    .frame(width: 80, height: 50)
                    .background(tipPercent == 0 ? Color.blue  : Color.theme.backgroundColor)
                    .foregroundColor(Color.theme.primaryTextColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.theme.primaryTextColor, lineWidth: 2)
                    )
                    .onTapGesture {
                        tipPercent = 0
                        tipValue = 0
                    }
                    
                    VStack(alignment: .leading) {
                        Text("10%")
                            .font(.system(size: 17, weight: .semibold))
                        
                        
                            .padding()
                    }
                    .frame(width: 80, height: 50)
                    .background(tipPercent == 10 ? Color.blue  : Color.theme.backgroundColor)
                    .foregroundColor(Color.theme.primaryTextColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.theme.primaryTextColor, lineWidth: 2)
                    )
                    .onTapGesture {
                        tipPercent = 10
                        tipValue = trip.tripCost * 0.1
                    }
                    
                    
                    VStack(alignment: .leading) {
                        Text("20%")
                            .font(.system(size: 17, weight: .semibold))
                        
                        
                            .padding()
                    }
                    .frame(width: 80, height: 50)
                    .background(tipPercent == 20 ? Color.blue  : Color.theme.backgroundColor)
                    .foregroundColor(Color.theme.primaryTextColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.theme.primaryTextColor, lineWidth: 2)
                    )
                    .onTapGesture {
                        tipPercent = 20
                        tipValue = trip.tripCost * 0.2
                    }
                    
                    VStack(alignment: .leading) {
                        Text("30%")
                            .font(.system(size: 17, weight: .semibold))
                        
                        
                            .padding()
                    }
                    .frame(width: 80, height: 50)
                    .background(tipPercent == 30 ? Color.blue  : Color.theme.backgroundColor)
                    .foregroundColor(Color.theme.primaryTextColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.theme.primaryTextColor, lineWidth: 2)
                    )
                    .onTapGesture {
                        tipPercent = 30
                        tipValue = trip.tripCost * 0.3
                    }
                    
                }
                .padding(.horizontal)
                
                Text("Rate driver")
                    .padding(.top, 10)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(rating < 1 ? Color.theme.primaryTextColor : Color(.systemYellow))
                        .imageScale(.large)
                        .onTapGesture {
                            if rating == 1 {
                                rating = 0
                            } else {
                                rating = 1
                            }
                        }
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(rating < 2 ? Color.theme.primaryTextColor : Color(.systemYellow))
                        .imageScale(.large)
                        .onTapGesture {
                            if rating == 2 {
                                rating = 0
                            } else {
                                rating = 2
                            }
                        }
                        
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(rating < 3 ? Color.theme.primaryTextColor : Color(.systemYellow))
                        .imageScale(.large)
                        .onTapGesture {
                            if rating == 3 {
                                rating = 0
                            } else {
                                rating = 3
                            }
                        }
                        
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(rating < 4 ? Color.theme.primaryTextColor : Color(.systemYellow))
                        .imageScale(.large)
                        .onTapGesture {
                            if rating == 4 {
                                rating = 0
                            } else {
                                rating = 4
                            }
                        }
                        
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(rating < 5 ? Color.theme.primaryTextColor : Color(.systemYellow))
                        .imageScale(.large)
                        .onTapGesture {
                            if rating == 5 {
                                rating = 0
                            } else {
                                rating = 5
                            }
                        }
                }
                .padding(.bottom, 30)
                .padding(.top, 7)
            }
            
            
            Button {
                appState.mapState = .noInput
                
                if authViewModel.user!.type == .passenger {
                    let _ = authViewModel.rewardDriver(tripId: trip.tripId, tip: tipPercent, rating: rating)
                }
            } label: {
                Text("OK")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            
        }
        .padding(.bottom, 25)
        .frame(maxWidth: .infinity)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secondaryBackgroundColor, radius: 20)
    }
}

//struct TripCompletedView_Previews: PreviewProvider {
//    static var previews: some View {
//        TripCompletedView()
//    }
//}
