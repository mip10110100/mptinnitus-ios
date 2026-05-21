//
//  AboutTinnitusPlaceholderView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct AboutTinnitusPlaceholderView: View {
    var body: some View {
        PlaceholderScreenView(
            title: "About Tinnitus",
            subtitle: "This educational overview is not available right now.",
            systemImage: "ear"
        )
    }
}

#Preview {
    NavigationStack {
        AboutTinnitusPlaceholderView()
    }
}
