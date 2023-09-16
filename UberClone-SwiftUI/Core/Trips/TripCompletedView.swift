//
//  TripCompletedView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 16.09.23.
//

import SwiftUI

struct TripCompletedView: View {
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            Text("This trip has been completed")
                .padding(.vertical)
            
            Button {
                appState.mapState = .noInput
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

struct TripCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        TripCompletedView()
    }
}
