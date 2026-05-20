//
//  SoundTherapyAnnexPlaceholderView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct SoundTherapyAnnexPlaceholderView: View {
    var body: some View {
        PlaceholderScreenView(
            title: AppTab.soundAnnex.fullTitle,
            subtitle: "The sound therapy annex destination is reserved for future local sound tools and samples.",
            systemImage: AppTab.soundAnnex.systemImage
        )
    }
}

#Preview {
    NavigationStack {
        SoundTherapyAnnexPlaceholderView()
    }
}
