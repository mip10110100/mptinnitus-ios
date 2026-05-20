//
//  ManifestDebugStatusView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

#if DEBUG
struct ManifestDebugStatusView: View {
    let snapshot: ManifestSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Label("Manifest Loader", systemImage: "curlybraces")
                .font(.headline)

            LazyVGrid(columns: columns, alignment: .leading, spacing: MPTTheme.Spacing.small) {
                countView("Routes", snapshot.debugCounts.routes)
                countView("Screens", snapshot.debugCounts.screens)
                countView("Sections", snapshot.debugCounts.sections)
                countView("Audio", snapshot.debugCounts.audioItems)
                countView("Visuals", snapshot.debugCounts.visualItems)
                countView("Safety", snapshot.debugCounts.safetyScopes)
                countView("Samples", snapshot.debugCounts.soundSamplePlaceholders)
                countView("Placeholders", snapshot.debugCounts.visualPlaceholders)
            }

            if snapshot.issues.isEmpty {
                Label("No manifest validation issues", systemImage: "checkmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                    Label("\(snapshot.issues.count) manifest issue(s)", systemImage: "exclamationmark.triangle")
                        .font(.footnote.weight(.semibold))

                    ForEach(snapshot.issues.prefix(4)) { issue in
                        Text("\(issue.source): \(issue.message)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .leading)
        ]
    }

    private func countView(_ label: String, _ count: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(count)")
                .font(.subheadline.weight(.semibold))
        }
    }
}

#Preview {
    ManifestDebugStatusView(snapshot: .empty)
        .padding()
        .background(MPTTheme.screenBackground)
}
#endif
