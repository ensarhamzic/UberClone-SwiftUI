//
//  LocationSearchActivationView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI

struct LocationSearchActivationView: View {
    //    @EnvironmentObject var authViewModel: AuthViewModel
    
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                            .font(.caption)
                            .foregroundColor(Color.theme.primaryTextColor)
                                .padding()
                                .background(Color.theme.backgroundColor)

                Text("Where to?")
                    .foregroundColor(Color(.darkGray))

                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 120, height: 50)
            .background(
                Rectangle()
                    .fill(Color.theme.backgroundColor)
            )
            .cornerRadius(20)


        }
                    .cornerRadius(30)
                .background(Color.white.opacity(0))
                .padding(.top, 4)
                .padding(.trailing, 30)
                .frame(maxWidth: .infinity, alignment: .trailing)

        
    
        
    }
}

struct LocationInputActivationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchActivationView()
    }
}

