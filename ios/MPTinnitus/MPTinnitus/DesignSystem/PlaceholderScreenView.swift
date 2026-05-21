//
//  PlaceholderScreenView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct PlaceholderScreenView<Footer: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    private let footer: Footer

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.footer = footer()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    Image(systemName: systemImage)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(MPTTheme.accentColor)

                    Text(title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(MPTTheme.Spacing.large)
                .background(MPTTheme.surfaceBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text("Local content unavailable")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(MPTTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                footer
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension PlaceholderScreenView where Footer == EmptyView {
    init(
        title: String,
        subtitle: String,
        systemImage: String
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage
        ) {
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        PlaceholderScreenView(
            title: "Library / Table of Contents",
            subtitle: "The module list is not available right now.",
            systemImage: "list.bullet.rectangle"
        )
    }
}
