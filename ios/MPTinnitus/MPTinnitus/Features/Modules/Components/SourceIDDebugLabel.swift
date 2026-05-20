//
//  SourceIDDebugLabel.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct SourceIDDebugLabel: View {
    let title: String
    let ids: [String]

    init(_ title: String, ids: [String]) {
        self.title = title
        self.ids = ids.filter { !$0.isEmpty }
    }

    var body: some View {
        Group {
        #if DEBUG
            if !ids.isEmpty {
                Text("\(title): \(ids.joined(separator: ", "))")
                    .font(.caption2.monospaced())
                    .foregroundStyle(MPTTheme.secondaryText)
                    .textSelection(.enabled)
                    .accessibilityLabel("\(title) \(ids.joined(separator: ", "))")
            }
        #else
            EmptyView()
        #endif
        }
    }
}
