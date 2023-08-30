//
//  SavedLocationMapView.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 26.08.23.
//

import SwiftUI
import MapKit

struct SaveLocationMapView: View {
    var buttonClicked: (_ coordinate: CLLocationCoordinate2D?) -> Void
    var savedCoordinate: Location?
    @Environment(\.dismiss) var dismiss
    
    @State private var chosenLocation: CLLocationCoordinate2D? = nil

    var body: some View {
        ZStack {
            SaveLocationMapViewRepresentable(mapTapped: mapTapped(_:), savedCoordinate: savedCoordinate)
                 .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Button {
                    if chosenLocation != nil {
                        buttonClicked(chosenLocation)
                        dismiss()
                    }
                } label : {
                    HStack {
                        Text("Save location")
                            .foregroundColor(Color.theme.primaryTextColor)
                    }
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                }
                .background((Color.theme.backgroundColor))
                .cornerRadius(15)
            }
        }
    }
    
    func mapTapped(_ coordinate: CLLocationCoordinate2D) {
        chosenLocation = coordinate
    }
}

//struct SavedLocationMapView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        SaveLocationMapView(saveButtonClicked)
//    }
//}
