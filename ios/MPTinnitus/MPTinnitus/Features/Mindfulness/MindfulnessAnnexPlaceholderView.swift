//
//  MindfulnessAnnexPlaceholderView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct MindfulnessAnnexPlaceholderView: View {
    var body: some View {
        PlaceholderScreenView(
            title: AppTab.mindfulnessAnnex.fullTitle,
            subtitle: "Mindfulness practices are not available right now.",
            systemImage: AppTab.mindfulnessAnnex.systemImage
        )
    }
}

#Preview {
    NavigationStack {
        MindfulnessAnnexPlaceholderView()
    }
}
