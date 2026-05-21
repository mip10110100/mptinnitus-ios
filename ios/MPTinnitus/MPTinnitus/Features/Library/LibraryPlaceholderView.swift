//
//  LibraryPlaceholderView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct LibraryPlaceholderView: View {
    let manifestSnapshot: ManifestSnapshot

    init(manifestSnapshot: ManifestSnapshot = .empty) {
        self.manifestSnapshot = manifestSnapshot
    }

    var body: some View {
        PlaceholderScreenView(
            title: AppTab.library.fullTitle,
            subtitle: "The table of contents is not available right now.",
            systemImage: AppTab.library.systemImage
        ) {
            #if DEBUG
            ManifestDebugStatusView(snapshot: manifestSnapshot)
            #endif
        }
    }
}

#Preview {
    NavigationStack {
        LibraryPlaceholderView()
    }
}
