//
//  LocationShortcutView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 26.08.23.
//

import SwiftUI

struct LocationShortcutView: View {
    let imageName: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .imageScale(.small)
                .foregroundColor(Color.theme.primaryTextColor)
                .fontWeight(.bold)
            Text(title)
                .foregroundColor(Color.theme.primaryTextColor)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .frame(width: 110, height: 40)
        .background(Color.theme.backgroundColor)
        .cornerRadius(20)
        .shadow(color: .black, radius: 6)
    }
}

struct LocationShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        LocationShortcutView(imageName: "house", title: "Home")
    }
}
