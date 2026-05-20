//
//  ModuleList.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ModuleList: View {
    let modules: [StaticModule]

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            ForEach(modules) { module in
                ModuleCard(module: module)
            }
        }
    }
}
