//
//  MPTTheme.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

enum MPTTheme {
    static let accentColor = Color.accentColor
    static let screenBackground = Color(.systemGroupedBackground)
    static let surfaceBackground = Color(.secondarySystemGroupedBackground)
    static let secondaryText = Color.secondary

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let screen: CGFloat = 20
        static let bottomScrollContent: CGFloat = 120
    }
}
