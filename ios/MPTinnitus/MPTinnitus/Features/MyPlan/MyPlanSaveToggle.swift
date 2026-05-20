//
//  MyPlanSaveToggle.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftData
import SwiftUI

struct MyPlanSaveToggle: View {
    let descriptor: MyPlanItemDescriptor

    @Environment(\.modelContext) private var modelContext
    @Query private var myPlanItems: [MyPlanItemRecord]
    @State private var errorMessage: String?

    private var isSaved: Bool {
        MyPlanLocalStore.activeItem(in: myPlanItems, matching: descriptor) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                toggleSavedState()
            } label: {
                Label(
                    isSaved ? "Saved to My Plan" : "Add to My Plan",
                    systemImage: isSaved ? "checkmark.square.fill" : "square"
                )
            }
            .buttonStyle(.bordered)
            .tint(isSaved ? MPTTheme.accentColor : .secondary)
            .accessibilityValue(isSaved ? "Selected" : "Not selected")
            .accessibilityHint("Toggles whether this item is stored locally in My Plan.")

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func toggleSavedState() {
        errorMessage = nil

        do {
            try MyPlanLocalStore.setSaved(
                !isSaved,
                descriptor: descriptor,
                existingItems: myPlanItems,
                modelContext: modelContext
            )
        } catch {
            errorMessage = "Could not update My Plan."

            #if DEBUG
            print("[MPTinnitus][MyPlan] Save toggle failed for \(descriptor.id): \(error.localizedDescription)")
            #endif
        }
    }
}
