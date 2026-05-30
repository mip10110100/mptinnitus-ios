//
//  MVPStaticVisualAssets.swift
//  MPTinnitus
//
//  Created by Codex on 5/30/26.
//

import SwiftUI
import UIKit

struct MVPStaticVisualAsset: Equatable {
    let id: String
    let title: String
    let assetPath: String
    let altText: String

    static func asset(for visualId: String) -> MVPStaticVisualAsset? {
        switch visualId {
        case "VIS-001":
            MVPStaticVisualAsset(
                id: "visual.body_mind_life_model",
                title: "Body / Mind / Life Model",
                assetPath: "visuals/body_mind_life_model.png",
                altText: "Diagram showing tinnitus management across body, mind, and life areas."
            )
        case "VIS-003":
            MVPStaticVisualAsset(
                id: "visual.sound_therapy_thermometer",
                title: "Sound Therapy Thermometer",
                assetPath: "visuals/sound_therapy_thermometer.png",
                altText: "Thermometer-style guide showing sound therapy volume from too low to too loud, with a comfortable overlap zone."
            )
        case "VIS-007", "VIS-032":
            MVPStaticVisualAsset(
                id: "visual.tug_of_war",
                title: "Tug-of-War",
                assetPath: "visuals/tug_of_war.png",
                altText: "Illustration of struggling with tinnitus as a tug-of-war, used to introduce acceptance and letting go of the struggle."
            )
        case "VIS-017", "VIS-033":
            MVPStaticVisualAsset(
                id: "visual.thoughts_feelings_behaviors_cycle",
                title: "Thoughts / Feelings / Behaviors Cycle",
                assetPath: "visuals/thoughts_feelings_behaviors_cycle.png",
                altText: "Cycle diagram showing how thoughts, feelings, and behaviors can influence each other."
            )
        case "VIS-021":
            MVPStaticVisualAsset(
                id: "visual.self_compassion_response_card",
                title: "Self-Compassion Response Card",
                assetPath: "visuals/self_compassion_response_card.png",
                altText: "Prompt card showing self-kindness, common humanity, and mindfulness as parts of a self-compassionate response."
            )
        default:
            nil
        }
    }

    func image(bundle: Bundle = .main) -> UIImage? {
        let nsPath = assetPath as NSString
        let filename = nsPath.lastPathComponent
        let filenamePath = filename as NSString
        let resourceName = filenamePath.deletingPathExtension
        let fileExtension = filenamePath.pathExtension

        if let url = bundle.resourceURL?.appendingPathComponent(assetPath),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }

        if let url = bundle.url(forResource: resourceName, withExtension: fileExtension),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }

        if let image = UIImage(named: resourceName) {
            return image
        }

        return nil
    }
}

struct MVPStaticVisualImageCard<MissingContent: View>: View {
    let asset: MVPStaticVisualAsset
    let caption: String?
    private let missingContent: MissingContent

    init(
        asset: MVPStaticVisualAsset,
        caption: String? = nil,
        @ViewBuilder missingContent: () -> MissingContent
    ) {
        self.asset = asset
        self.caption = caption
        self.missingContent = missingContent()
    }

    var body: some View {
        if let image = asset.image() {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(asset.altText)

                if let caption {
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(MPTTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            missingContent
        }
    }
}
