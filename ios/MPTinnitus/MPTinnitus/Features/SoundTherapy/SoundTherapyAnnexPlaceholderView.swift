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
            subtitle: "Sound therapy tools are not available right now.",
            systemImage: AppTab.soundAnnex.systemImage
        )
    }
}

#Preview {
    NavigationStack {
        SoundTherapyAnnexPlaceholderView()
    }
}
