//
//  AppState.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 06.09.23.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var mapState: MapViewState = .noInput
}
