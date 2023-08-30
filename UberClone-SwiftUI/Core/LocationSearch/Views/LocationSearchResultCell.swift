//
//  LocationSearchResultCell.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI
import MapKit

struct LocationSearchResultCell: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .foregroundColor(Color.blue)
                .frame(width: 40, height: 40)
                .accentColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(Color(.gray))
                
                Divider()
            }
            .padding(.leading, 8)
            .padding(.vertical, 8)
            
            Spacer()
        }
        .padding(.leading)
    }
}

struct LocationSearchResultCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchResultCell(title: "Test", subtitle: "Test test")
    }
}
