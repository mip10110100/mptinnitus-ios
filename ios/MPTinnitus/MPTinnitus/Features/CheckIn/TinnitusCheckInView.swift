//
//  TinnitusCheckInView.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import SwiftUI

struct TinnitusCheckInView: View {
    let source: CheckInSessionSource
    let moduleLibrary: StaticModuleLibrary
    let questionLibrary: CheckInQuestionLibrary
    let onComplete: (() -> Void)?
    let onSkip: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = CheckInStore()
    @State private var phase: CheckInFlowPhase
    @State private var currentIndex = 0
    @State private var selections: [String: CheckInScaleSelection] = [:]
    @State private var completedSession: CheckInSession?

    init(
        source: CheckInSessionSource = .myPlan,
        moduleLibrary: StaticModuleLibrary = StaticModuleLibraryLoader().loadLibrary(),
        questionLibrary: CheckInQuestionLibrary = CheckInQuestionLibraryLoader().loadLibrary(),
        showsIntro: Bool = true,
        onComplete: (() -> Void)? = nil,
        onSkip: (() -> Void)? = nil
    ) {
        self.source = source
        self.moduleLibrary = moduleLibrary
        self.questionLibrary = questionLibrary
        self.onComplete = onComplete
        self.onSkip = onSkip
        _phase = State(initialValue: showsIntro ? .intro : .questions)
    }

    private var questions: [CheckInQuestion] {
        questionLibrary.questions
    }

    private var currentQuestion: CheckInQuestion? {
        guard questions.indices.contains(currentIndex) else {
            return nil
        }

        return questions[currentIndex]
    }

    private var isCurrentQuestionAnswered: Bool {
        guard let currentQuestion else {
            return false
        }

        return selections[currentQuestion.id] != nil
    }

    private var allowsRecommendationNavigation: Bool {
        onComplete == nil && onSkip == nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                switch phase {
                case .intro:
                    introView
                case .questions:
                    questionView
                case .completion:
                    completionView
                }
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle("Tinnitus Check-In")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introView: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
            checkInHeader

            VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                Text("Before you begin, you can answer a few questions about how tinnitus is affecting you right now. This helps build your starting plan. Your answers are for personal tracking and app recommendations only. This is not a diagnosis or a standardized clinical score. You can skip this and come back later.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Your check-in answers are stored on this device.")
                    .font(.subheadline)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .checkInCard()

            VStack(spacing: MPTTheme.Spacing.medium) {
                Button {
                    phase = .questions
                } label: {
                    Label("Start check-in", systemImage: "checklist")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    finishSkipped()
                } label: {
                    Label("Skip for now", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var questionView: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
            checkInHeader

            if let currentQuestion {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    Text("\(currentIndex + 1) of \(questions.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MPTTheme.accentColor)

                    Text(questionLibrary.timeWindow)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MPTTheme.secondaryText)

                    Text(currentQuestion.prompt)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    CheckInDotScaleView(
                        selection: Binding(
                            get: { selections[currentQuestion.id] },
                            set: { selections[currentQuestion.id] = $0 }
                        )
                    )
                }
                .checkInCard()

                HStack(spacing: MPTTheme.Spacing.small) {
                    Button {
                        moveBack()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                    .buttonStyle(.bordered)
                    .disabled(currentIndex == 0)

                    Spacer()

                    Button {
                        moveNextOrSave()
                    } label: {
                        Label(currentIndex == questions.count - 1 ? "Save check-in" : "Next", systemImage: "chevron.right")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isCurrentQuestionAnswered)
                }

                Button {
                    finishSkipped()
                } label: {
                    Text("Skip for now")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Text("The check-in questions are not available right now.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .checkInCard()
            }
        }
    }

    private var completionView: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
            checkInHeader

            if let completedSession {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    Text("Your starting plan")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("Your check-in suggests a good starting focus may be…")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Use this as a starting point. You can change your plan anytime.")
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .checkInCard()

                recommendationSection(
                    title: "Start here",
                    recommendations: completedSession.recommendations.filter(\.isBaseline)
                )

                let personalized = completedSession.recommendations.filter { !$0.isBaseline }
                if !personalized.isEmpty {
                    recommendationSection(
                        title: "Suggested next",
                        recommendations: personalized
                    )
                }

                let trendMessages = CheckInScoring.trendMessages(
                    latest: completedSession,
                    previous: store.previousSession
                )
                if !trendMessages.isEmpty {
                    VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                        SectionHeader("Compared with last time")
                        ForEach(trendMessages, id: \.self) { message in
                            Label(message, systemImage: "arrow.triangle.2.circlepath")
                                .font(.subheadline)
                                .foregroundStyle(MPTTheme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .checkInCard()
                } else if store.sessions.count > 1 {
                    VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                        SectionHeader("Compared with last time")
                        Text("You have completed \(store.sessions.count) check-ins.")
                            .font(.body)
                            .foregroundStyle(MPTTheme.secondaryText)
                    }
                    .checkInCard()
                }

                Button {
                    finishCompleted()
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if let errorMessage = store.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var checkInHeader: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "checklist.checked")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text("Tinnitus Check-In")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("This is not a diagnostic test or a standardized clinical measure. It is a private check-in to help you notice patterns and choose a starting plan.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .checkInCard()
    }

    private func recommendationSection(
        title: String,
        recommendations: [ModuleRecommendation]
    ) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader(title)

            ForEach(recommendations) { recommendation in
                if allowsRecommendationNavigation {
                    NavigationLink(value: AppRoute.module(recommendation.moduleId)) {
                        recommendationRow(recommendation, showsChevron: true)
                    }
                    .buttonStyle(.plain)
                } else {
                    recommendationRow(recommendation, showsChevron: false)
                }
            }
        }
    }

    private func recommendationRow(_ recommendation: ModuleRecommendation, showsChevron: Bool) -> some View {
        HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: moduleLibrary.module(id: recommendation.moduleId)?.systemImage ?? "list.bullet.rectangle")
                .font(.title3.weight(.semibold))
                .foregroundStyle(MPTTheme.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(recommendation.reasonText)
                    .font(.subheadline)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MPTTheme.secondaryText)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func moveBack() {
        currentIndex = max(currentIndex - 1, 0)
    }

    private func moveNextOrSave() {
        guard currentIndex < questions.count else {
            return
        }

        if currentIndex < questions.count - 1 {
            currentIndex += 1
            return
        }

        completedSession = store.saveSession(
            source: source,
            questions: questions,
            selections: selections,
            library: moduleLibrary
        )
        phase = .completion
    }

    private func finishSkipped() {
        if let onSkip {
            onSkip()
        } else {
            dismiss()
        }
    }

    private func finishCompleted() {
        if let onComplete {
            onComplete()
        } else {
            dismiss()
        }
    }
}

private enum CheckInFlowPhase {
    case intro
    case questions
    case completion
}

private extension View {
    func checkInCard() -> some View {
        self
            .padding(MPTTheme.Spacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
