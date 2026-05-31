//
//  BreathingPacerVisualView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Combine
import SwiftUI

struct BreathingPacerPattern: Hashable, Identifiable {
    let id: String
    let title: String
    let inhale: Int
    let holdAfterInhale: Int
    let exhale: Int
    let holdAfterExhale: Int
    let description: String

    var totalSeconds: Int {
        max(1, inhale + holdAfterInhale + exhale + holdAfterExhale)
    }

    var rhythmDescription: String {
        var parts = ["inhale \(inhale)"]
        if holdAfterInhale > 0 {
            parts.append("hold \(holdAfterInhale)")
        }
        parts.append("exhale \(exhale)")
        if holdAfterExhale > 0 {
            parts.append("pause \(holdAfterExhale)")
        }
        return parts.joined(separator: ", ")
    }

    static let defaultPattern = BreathingPacerPattern(
        id: "4-2-6",
        title: "4-2-6 Extended Exhale with Pause",
        inhale: 4,
        holdAfterInhale: 2,
        exhale: 6,
        holdAfterExhale: 0,
        description: "A slower pattern with a short pause and a longer exhale."
    )

    static let mindfulnessPracticeOptions: [BreathingPacerPattern] = [
        BreathingPacerPattern(
            id: "4-4",
            title: "4-4 Even Breathing",
            inhale: 4,
            holdAfterInhale: 0,
            exhale: 4,
            holdAfterExhale: 0,
            description: "A simple inhale-and-exhale rhythm."
        ),
        BreathingPacerPattern(
            id: "4-2-4",
            title: "4-2-4 Balanced Breathing",
            inhale: 4,
            holdAfterInhale: 2,
            exhale: 4,
            holdAfterExhale: 0,
            description: "A steady breathing pattern with a short pause after the inhale."
        ),
        BreathingPacerPattern(
            id: "4-6",
            title: "4-6 Extended Exhale",
            inhale: 4,
            holdAfterInhale: 0,
            exhale: 6,
            holdAfterExhale: 0,
            description: "A gentle pattern with a longer exhale."
        ),
        .defaultPattern
    ]
}

struct BreathingPacerVisualView: View {
    let visual: StaticVisualReference
    let module: StaticModule
    let pattern: BreathingPacerPattern

    @State private var isRunning = true
    @State private var cycleSecond = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(
        visual: StaticVisualReference,
        module: StaticModule,
        pattern: BreathingPacerPattern = .defaultPattern
    ) {
        self.visual = visual
        self.module = module
        self.pattern = pattern
    }

    private var totalSeconds: Int {
        pattern.totalSeconds
    }

    private var phase: BreathPhase {
        BreathPhase(second: cycleSecond, pattern: pattern)
    }

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                pacerPanel
                phaseList
                VisualExerciseLink(
                    exerciseId: "I-011",
                    title: "Open Deep Breath Check-In"
                )
            }
        }
        .onReceive(timer) { _ in
            guard isRunning else {
                return
            }

            withAnimation(.easeInOut(duration: 0.35)) {
                cycleSecond = (cycleSecond + 1) % totalSeconds
            }
        }
    }

    private var pacerPanel: some View {
        VStack(spacing: MPTTheme.Spacing.large) {
            ZStack {
                Circle()
                    .fill(MPTTheme.accentColor.opacity(0.12))
                    .frame(width: phase.circleSize, height: phase.circleSize)

                Circle()
                    .stroke(MPTTheme.accentColor, lineWidth: 4)
                    .frame(width: phase.circleSize, height: phase.circleSize)

                VStack(spacing: 4) {
                    Text(phase.title)
                        .font(.title2.weight(.semibold))

                    Text("\(phaseRemainingCount)")
                        .font(.largeTitle.weight(.bold))
                        .monospacedDigit()
                }
                .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .accessibilityLabel("Breathing pacer \(phase.title), count \(phaseRemainingCount)")

            HStack(spacing: MPTTheme.Spacing.small) {
                Button {
                    isRunning.toggle()
                } label: {
                    Label(isRunning ? "Pause" : "Resume", systemImage: isRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        cycleSecond = 0
                        isRunning = true
                    }
                } label: {
                    Label("Restart", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("\(pattern.description) Rhythm: \(pattern.rhythmDescription).")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Return to natural breathing or stop the practice if you feel uncomfortable, dizzy, short of breath, or more anxious.")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var phaseList: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            BreathPhaseRow(title: "Inhale", detail: "\(pattern.inhale) seconds", isActive: phase == .inhale)
            if pattern.holdAfterInhale > 0 {
                BreathPhaseRow(title: "Hold", detail: "\(pattern.holdAfterInhale) seconds", isActive: phase == .holdAfterInhale)
            }
            BreathPhaseRow(title: "Exhale", detail: "\(pattern.exhale) seconds", isActive: phase == .exhale)
            if pattern.holdAfterExhale > 0 {
                BreathPhaseRow(title: "Pause", detail: "\(pattern.holdAfterExhale) seconds", isActive: phase == .holdAfterExhale)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var phaseRemainingCount: Int {
        let remaining: Int
        switch phase {
        case .inhale:
            remaining = pattern.inhale - cycleSecond
        case .holdAfterInhale:
            remaining = pattern.inhale + pattern.holdAfterInhale - cycleSecond
        case .exhale:
            remaining = pattern.inhale + pattern.holdAfterInhale + pattern.exhale - cycleSecond
        case .holdAfterExhale:
            remaining = totalSeconds - cycleSecond
        }
        return max(1, remaining)
    }
}

private enum BreathPhase: Equatable {
    case inhale
    case holdAfterInhale
    case exhale
    case holdAfterExhale

    init(second: Int, pattern: BreathingPacerPattern) {
        var boundary = pattern.inhale
        if second < boundary {
            self = .inhale
            return
        }

        boundary += pattern.holdAfterInhale
        if pattern.holdAfterInhale > 0, second < boundary {
            self = .holdAfterInhale
            return
        }

        boundary += pattern.exhale
        if second < boundary {
            self = .exhale
            return
        }

        self = .holdAfterExhale
    }

    var title: String {
        switch self {
        case .inhale:
            "Inhale"
        case .holdAfterInhale:
            "Hold"
        case .exhale:
            "Exhale"
        case .holdAfterExhale:
            "Pause"
        }
    }

    var circleSize: CGFloat {
        switch self {
        case .inhale:
            178
        case .holdAfterInhale, .holdAfterExhale:
            192
        case .exhale:
            142
        }
    }
}

private struct BreathPhaseRow: View {
    let title: String
    let detail: String
    let isActive: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(MPTTheme.secondaryText)
        }
        .padding(MPTTheme.Spacing.small)
        .background(isActive ? MPTTheme.accentColor.opacity(0.12) : Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
