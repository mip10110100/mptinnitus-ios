//
//  TranscriptDisclosure.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct TranscriptDisclosure: View {
    let transcript: String

    @AppStorage("mptinnitus.transcriptsExpandedByDefault")
    private var transcriptsExpandedByDefault = false
    @State private var userExpandedOverride: Bool?

    private var isExpanded: Binding<Bool> {
        Binding(
            get: { userExpandedOverride ?? transcriptsExpandedByDefault },
            set: { userExpandedOverride = $0 }
        )
    }

    var body: some View {
        DisclosureGroup(isExpanded: isExpanded) {
            Text(transcript.isEmpty ? "Transcript is not available for this audio yet." : transcript)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, MPTTheme.Spacing.small)
        } label: {
            Label("Transcript", systemImage: "text.quote")
                .font(.subheadline.weight(.semibold))
        }
        .accessibilityHint(transcriptsExpandedByDefault ? "Transcript follows the settings default." : "Transcript starts collapsed.")
    }
}
