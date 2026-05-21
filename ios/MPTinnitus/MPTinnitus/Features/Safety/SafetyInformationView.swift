//
//  SafetyInformationView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct SafetyInformationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                safetyBlock(
                    title: "Educational Scope",
                    body: "MPTinnitus is an educational tinnitus management companion. It is not medical advice, diagnosis, treatment, therapy, or a replacement for audiology, ENT, primary care, mental health care, sleep medicine, emergency care, or other appropriate care."
                )

                safetyBlock(
                    title: "Not a Crisis Resource",
                    body: "If you feel unsafe or are in a mental health crisis, do not rely on this app. Seek immediate support through emergency services, crisis resources, or a qualified professional."
                )

                safetyBlock(
                    title: "Hearing and Medical Concerns",
                    body: "Sudden hearing changes, new neurological symptoms, pulsatile tinnitus, one-sided tinnitus, significant distress, or other medical concerns should be discussed with an appropriate clinician such as an audiologist, ENT, primary care clinician, or emergency service when urgent."
                )

                safetyBlock(
                    title: "Sleep Scope",
                    body: "This app provides sleep education, not sleep treatment. Persistent or severe sleep problems, suspected sleep apnea, or medical sleep concerns deserve professional evaluation."
                )

                safetyBlock(
                    title: "Sound Sensitivity",
                    body: "Do not push into painful sound. Use comfortable, controlled sound and seek professional guidance when sound sensitivity is severe or worsening."
                )

                safetyBlock(
                    title: "Local-Only MVP",
                    body: "This MVP does not require an account and does not transmit personal entries, preferences, journal content, or plan items."
                )
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(AppRoute.safetyInformation.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func safetyBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(body)
                .font(.body)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MPTTheme.Spacing.large)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        SafetyInformationView()
    }
}
