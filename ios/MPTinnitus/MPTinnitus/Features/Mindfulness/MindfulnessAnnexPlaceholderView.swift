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
            subtitle: "The mindfulness annex destination is reserved for future guided practice content.",
            systemImage: AppTab.mindfulnessAnnex.systemImage
        )
    }
}

#Preview {
    NavigationStack {
        MindfulnessAnnexPlaceholderView()
    }
}
