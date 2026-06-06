//
//  TinnitusSoundEstimateView.swift
//  MPTinnitus
//
//  Created by Codex on 5/31/26.
//

import SwiftUI

struct TinnitusSoundEstimateView: View {
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject private var sampleController: SoundSampleController
    @StateObject private var profileStore = TinnitusSoundProfileStore()
    @StateObject private var pitchEngine = TinnitusPitchMatchAudioEngine()

    @State private var pitchSliderValue = TinnitusPitchScale.sliderValue(for: 1_000)
    @State private var toneVolume = 0.0
    @State private var loudnessEstimate = 0.0
    @State private var matchConfidence: TinnitusMatchConfidence = .closeEnough
    @State private var laterality: TinnitusLaterality = .notSure
    @State private var didLoadProfile = false
    @State private var saveMessage: String?
    @State private var playbackMode: PitchEstimatePlaybackMode?

    init(sampleController: SoundSampleController) {
        self.sampleController = sampleController
    }

    private var frequencyHz: Double {
        TinnitusPitchScale.frequencyHz(for: pitchSliderValue)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header

                if let profile = profileStore.profile {
                    savedProfileSummary(profile)
                } else {
                    noSavedEstimateCard
                }

                pitchEstimateSection
                loudnessEstimateSection
                saveSection
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle("Tinnitus sound estimate")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProfileIfNeeded()
            sampleController.onWillStartPlayback = { [weak pitchEngine] in
                pitchEngine?.stop()
            }
        }
        .onDisappear {
            stopTone()
            resetLiveToneControls()
            sampleController.onWillStartPlayback = nil
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                stopTone()
                resetLiveToneControls()
            }
        }
        .onChange(of: pitchSliderValue) { _, _ in
            updateToneIfNeeded()
        }
        .onChange(of: toneVolume) { _, _ in
            updateToneIfNeeded()
        }
        .onChange(of: loudnessEstimate) { _, _ in
            updateToneIfNeeded()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "waveform.and.magnifyingglass")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text("Tinnitus sound estimate")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Estimate your tinnitus pitch and optional loudness. An exact match is not required.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("This local profile stays on this device and can help personalize sound options later.")
                .font(.subheadline)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var pitchEstimateSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                "1. Pitch estimate",
                subtitle: "Move the slider until the tone is close to your tinnitus. It does not need to be exact."
            )

            VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                HStack {
                    Text("Pitch")
                        .font(.headline)
                    Spacer()
                    Text(formattedFrequency(frequencyHz))
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(MPTTheme.accentColor)
                }

                Slider(
                    value: $pitchSliderValue,
                    in: 0...1
                ) {
                    Text("Tinnitus pitch estimate")
                } minimumValueLabel: {
                    Text("100 Hz")
                        .font(.caption2)
                } maximumValueLabel: {
                    Text("14 kHz")
                        .font(.caption2)
                }
                .accessibilityLabel("Tinnitus pitch estimate")
                .accessibilityValue(formattedFrequency(frequencyHz))
                .accessibilityHint("Adjusts the pitch of the comparison tone.")

                VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                    HStack {
                        Text("Tone volume")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(toneVolumeLabel)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(MPTTheme.secondaryText)
                    }

                    Slider(
                        value: $toneVolume,
                        in: 0...1
                    ) {
                        Text("Tone volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker.slash")
                            .font(.caption)
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.2")
                            .font(.caption)
                    }
                    .accessibilityLabel("Tone volume")
                    .accessibilityValue(toneVolumeLabel)
                    .accessibilityHint("Starts at zero. Raise slowly until the pitch tone is comfortably audible.")

                    Text("Start at zero, then raise the tone volume slowly until it is comfortably audible.")
                        .font(.footnote)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: MPTTheme.Spacing.small) {
                    Button {
                        nudgePitch(octaveSteps: -1)
                    } label: {
                        Label("Down one step", systemImage: "minus")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint("Lowers the pitch by one small step.")

                    Button {
                        toggleTone(mode: .pitchPreview)
                    } label: {
                        Label(pitchPreviewButtonTitle, systemImage: pitchPreviewButtonIcon)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel(pitchPreviewButtonTitle)
                    .accessibilityHint("Plays or pauses the pitch comparison tone.")

                    Button {
                        nudgePitch(octaveSteps: 1)
                    } label: {
                        Label("Up one step", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint("Raises the pitch by one small step.")
                }

                Text("Headphones may help with pitch matching, especially for higher pitches. Phone speakers may not reproduce very high pitches accurately.")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Picker("Confidence", selection: $matchConfidence) {
                    ForEach(TinnitusMatchConfidence.allCases) { confidence in
                        Text(confidence.displayName).tag(confidence)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Laterality", selection: $laterality) {
                    ForEach(TinnitusLaterality.allCases) { side in
                        Text(side.displayName).tag(side)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(MPTTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var loudnessEstimateSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                "2. Loudness estimate",
                subtitle: "Start at the bottom. If you choose to compare loudness, raise the tone only until it is comfortably audible and roughly similar. Stop if it feels uncomfortable."
            )

            VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                HStack {
                    Text("Tone loudness")
                        .font(.headline)
                    Spacer()
                    Text(loudnessLabel)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(MPTTheme.accentColor)
                }

                Slider(
                    value: $loudnessEstimate,
                    in: 0...1
                ) {
                    Text("Optional tinnitus loudness estimate")
                } minimumValueLabel: {
                    Image(systemName: "speaker.slash")
                        .font(.caption)
                } maximumValueLabel: {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                }
                .accessibilityLabel("Optional tinnitus loudness estimate")
                .accessibilityValue(loudnessLabel)
                .accessibilityHint("Raises or lowers the capped comparison tone volume.")

                Button {
                    toggleTone(mode: .loudnessEstimate)
                } label: {
                    Label(loudnessButtonTitle, systemImage: loudnessButtonIcon)
                }
                .buttonStyle(.borderedProminent)
                .disabled(loudnessEstimate <= 0)
                .accessibilityLabel(loudnessButtonTitle)
                .accessibilityHint("Plays or pauses the tone at the selected capped loudness.")

                if loudnessEstimate <= 0 {
                    Text("Raise the loudness slightly before comparing. Keep it comfortable.")
                        .font(.footnote)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(MPTTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var saveSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Button {
                saveEstimate()
            } label: {
                Label("Save estimate", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if let saveMessage {
                Text(saveMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(MPTTheme.accentColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let errorMessage = profileStore.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var noSavedEstimateCard: some View {
        Label("No estimate saved yet. You can save one after comparing the tone.", systemImage: "tray")
            .font(.subheadline)
            .foregroundStyle(MPTTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
            .padding(MPTTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func savedProfileSummary(_ profile: TinnitusSoundProfile) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Label("Saved on this device", systemImage: "lock")
                .font(.headline)

            ProfileSummaryRow(label: "Pitch", value: formattedFrequency(profile.matchedFrequencyHz))
            ProfileSummaryRow(label: "Confidence", value: profile.matchConfidence.displayName)
            ProfileSummaryRow(label: "Laterality", value: profile.laterality.displayName)

            if let loudnessEstimate = profile.loudnessEstimate {
                ProfileSummaryRow(
                    label: "Loudness estimate",
                    value: "\(Int((loudnessEstimate * 100).rounded()))% of the capped range"
                )
            }

            ProfileSummaryRow(label: "Updated", value: profile.updatedAt.formatted(date: .abbreviated, time: .shortened))
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var pitchPreviewButtonTitle: String {
        pitchEngine.isPlaying && playbackMode == .pitchPreview ? "Pause tone" : "Play tone"
    }

    private var pitchPreviewButtonIcon: String {
        pitchEngine.isPlaying && playbackMode == .pitchPreview ? "pause.fill" : "play.fill"
    }

    private var loudnessButtonTitle: String {
        pitchEngine.isPlaying && playbackMode == .loudnessEstimate ? "Pause tone" : "Play at this loudness"
    }

    private var loudnessButtonIcon: String {
        pitchEngine.isPlaying && playbackMode == .loudnessEstimate ? "pause.fill" : "play.fill"
    }

    private var loudnessLabel: String {
        "\(Int((loudnessEstimate * 100).rounded()))% of capped range"
    }

    private var toneVolumeLabel: String {
        "\(Int((toneVolume * 100).rounded()))%"
    }

    private func loadProfileIfNeeded() {
        guard !didLoadProfile else {
            return
        }

        if let profile = profileStore.profile {
            pitchSliderValue = TinnitusPitchScale.sliderValue(for: profile.matchedFrequencyHz)
            matchConfidence = profile.matchConfidence
            laterality = profile.laterality
        }

        didLoadProfile = true
    }

    private func toggleTone(mode: PitchEstimatePlaybackMode) {
        if pitchEngine.isPlaying && playbackMode == mode {
            stopTone()
        } else {
            startTone(mode: mode)
        }
    }

    private func startTone(mode: PitchEstimatePlaybackMode) {
        sampleController.stop()
        playbackMode = mode
        pitchEngine.start(
            frequencyHz: frequencyHz,
            loudness: playbackLevel(for: mode)
        )
    }

    private func stopTone() {
        pitchEngine.stop()
        playbackMode = nil
    }

    private func updateToneIfNeeded() {
        guard pitchEngine.isPlaying, let playbackMode else {
            return
        }

        pitchEngine.update(
            frequencyHz: frequencyHz,
            loudness: playbackLevel(for: playbackMode)
        )
    }

    private func playbackLevel(for mode: PitchEstimatePlaybackMode) -> Double {
        switch mode {
        case .pitchPreview:
            toneVolume
        case .loudnessEstimate:
            loudnessEstimate
        }
    }

    private func resetLiveToneControls() {
        toneVolume = 0
        loudnessEstimate = 0
    }

    private func nudgePitch(octaveSteps: Int) {
        let multiplier = pow(2.0, Double(octaveSteps) / 12.0)
        let nextFrequency = min(
            max(frequencyHz * multiplier, TinnitusPitchScale.minFrequencyHz),
            TinnitusPitchScale.maxFrequencyHz
        )
        pitchSliderValue = TinnitusPitchScale.sliderValue(for: nextFrequency)
    }

    private func saveEstimate() {
        profileStore.save(
            matchedFrequencyHz: frequencyHz,
            loudnessEstimate: loudnessEstimate > 0 ? loudnessEstimate : nil,
            matchConfidence: matchConfidence,
            laterality: laterality
        )

        if profileStore.errorMessage == nil {
            saveMessage = "Saved on this device. You can update it later."
        }
    }

    private func formattedFrequency(_ frequencyHz: Double) -> String {
        if frequencyHz >= 1_000 {
            return String(format: "%.1f kHz", frequencyHz / 1_000)
        }

        return "\(Int(frequencyHz.rounded())) Hz"
    }
}

private enum PitchEstimatePlaybackMode {
    case pitchPreview
    case loudnessEstimate
}

private struct ProfileSummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer(minLength: MPTTheme.Spacing.medium)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(MPTTheme.secondaryText)
                .multilineTextAlignment(.trailing)
        }
    }
}
