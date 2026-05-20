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
            subtitle: "This route is reserved for the opening educational overview from the bundled content manifests.",
            systemImage: "ear"
        )
    }
}

#Preview {
    NavigationStack {
        AboutTinnitusPlaceholderView()
    }
}
