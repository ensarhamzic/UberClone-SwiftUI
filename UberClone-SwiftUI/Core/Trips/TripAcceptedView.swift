//
//  TripAcceptedView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 03.09.23.
//

import SwiftUI

struct TripAcceptedView: View {
    var body: some View {
        VStack {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            
            VStack{
                HStack {
                    Text("Your driver is on the way")
                        .font(.system(size: 20))
                        .lineLimit(2)
                        .fontWeight(.bold)
                        .padding(.trailing)
                    
                    Spacer()
                    
                    VStack {
                        Text("10")
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
                        Text("DRIVER")
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
                    
                    VStack(alignment: .center) {
                        Image("uber-x")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 64)
                        
                        HStack {
                            Text("Uber X")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.theme.primaryTextColor)
                        }
                    }
                    .padding(.bottom)
                }
                
                Divider()
            }
            .padding()
            
            
            Button {
               
            } label: {
                Text("CANCEL RIDE")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            
            
        }
        .padding(.bottom, 25)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secondaryBackgroundColor, radius: 20)
    }
}

struct TripAcceptedView_Previews: PreviewProvider {
    static var previews: some View {
        TripAcceptedView()
    }
}
