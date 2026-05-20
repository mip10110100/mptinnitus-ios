//
//  BreathingPacerVisualView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Combine
import SwiftUI

struct BreathingPacerVisualView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    @State private var isRunning = true
    @State private var cycleSecond = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let totalSeconds = 12

    private var phase: BreathPhase {
        BreathPhase(second: cycleSecond)
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

            Text("Default rhythm: inhale 4, hold 2, exhale 6. This is a visual guide only; adjust or stop if the pace does not fit.")
                .font(.footnote)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var phaseList: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            BreathPhaseRow(title: "Inhale", detail: "4 seconds", isActive: phase == .inhale)
            BreathPhaseRow(title: "Hold", detail: "2 seconds", isActive: phase == .hold)
            BreathPhaseRow(title: "Exhale", detail: "6 seconds", isActive: phase == .exhale)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var phaseRemainingCount: Int {
        switch phase {
        case .inhale:
            4 - cycleSecond
        case .hold:
            6 - cycleSecond
        case .exhale:
            totalSeconds - cycleSecond
        }
    }
}

private enum BreathPhase: Equatable {
    case inhale
    case hold
    case exhale

    init(second: Int) {
        if second < 4 {
            self = .inhale
        } else if second < 6 {
            self = .hold
        } else {
            self = .exhale
        }
    }

    var title: String {
        switch self {
        case .inhale:
            "Inhale"
        case .hold:
            "Hold"
        case .exhale:
            "Exhale"
        }
    }

    var circleSize: CGFloat {
        switch self {
        case .inhale:
            178
        case .hold:
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
