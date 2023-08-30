//
//  Color.swift
//  UberClone-SwiftUI
//
//  Created by Muhedin Alic on 23.08.23.
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}


struct ColorTheme {
    let primaryTextColor = Color("PrimaryTextColor")
    let backgroundColor = Color("BackgroundColor")
    let secondaryBackgroundColor = Color("SecondaryBackgroundColor")
    let systemBackgroundColor = Color("SystemBackgroundColor")
}
