import SwiftUI

struct ModuleOverviewScreen: View {
    let module: StaticModule
    let library: StaticModuleLibrary
    let exerciseDefinitionLibrary: ExerciseDefinitionLibrary
    @ObservedObject var audioController: AudioController
    @State private var expandedGroupIDs: Set<String> = []
    @State private var didInitializeGroups = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                moduleHeader

                learningSection

                if !implementedExercises.isEmpty {
                    practiceSection
                }

                if !module.relatedModules.isEmpty {
                    relatedModulesSection
                }

                if !module.safetyScopes.isEmpty {
                    ModuleSafetyScopeGroup(safetyScopes: module.safetyScopes)
                }
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground.ignoresSafeArea())
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            initializeExpandedGroupsIfNeeded()
            updateSectionAudioQueue()
        }
        .onChange(of: expandedGroupIDs) { _, _ in
            updateSectionAudioQueue()
        }
        .onDisappear {
            audioController.clearSectionAudioQueue(contextID: module.moduleId)
        }
    }

    private var moduleHeader: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            HStack(alignment: .top, spacing: MPTTheme.Spacing.medium) {
                Image(systemName: module.systemImage)
                    .font(.title2)
                    .foregroundStyle(MPTTheme.accentColor)
                    .frame(width: 44, height: 44)
                    .background(MPTTheme.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 8) {
                    Text(module.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(module.purpose)
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                }
            }

            Text(module.overviewMarkdown)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if let overviewAudio {
                ModuleHeaderAudioControl(audio: overviewAudio, audioController: audioController)
            }
        }
        .padding(MPTTheme.Spacing.large)
        .background(MPTTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.35))
        )
    }

    private var learningSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                "Learn",
                subtitle: "Read the key ideas first, then use the practice tools when you want to try them."
            )

            HStack(spacing: MPTTheme.Spacing.small) {
                Button("Expand all") {
                    expandedGroupIDs = Set(learningGroups.map(\.id))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Collapse all") {
                    expandedGroupIDs.removeAll()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer(minLength: MPTTheme.Spacing.small)
            }

            ForEach(learningGroups) { group in
                learningGroupSection(group)
            }
        }
    }

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                "Practice",
                subtitle: "Choose an exercise or tool you may want to come back to."
            )

            ForEach(implementedExercises, id: \.exerciseId) { exercise in
                ExerciseLaunchCard(exercise: exercise, module: module)
            }
        }
    }

    private var implementedExercises: [StaticExerciseItem] {
        module.exercises.filter { exercise in
            exerciseDefinitionLibrary.definition(id: exercise.exerciseId) != nil
        }
    }

    private var relatedModulesSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                "Continue",
                subtitle: "Related sections that build on this topic."
            )

            ForEach(relatedModules, id: \.id) { related in
                ModuleCard(module: related)
            }
        }
    }

    private var overviewAudio: StaticAudioItem? {
        module.audio.first { audio in
            audio.screenIds.contains(module.screenId) && audio.type.localizedCaseInsensitiveContains("overview")
        } ?? module.audio.first { audio in
            audio.title == module.title
        } ?? module.audio.first { audio in
            audio.type.localizedCaseInsensitiveContains("overview")
        }
    }

    private var relatedModules: [StaticModule] {
        module.relatedModules.compactMap { link in
            library.modules.first { related in
                related.moduleId == link.moduleId
            }
        }
    }

    private func audioItems(for card: StaticContentCard) -> [StaticAudioItem] {
        module.audio.filter { audio in
            audio.audioId != overviewAudio?.audioId
                && (card.audioIds.contains(audio.audioId)
                    || audio.screenIds.contains(card.screenId)
                    || audio.screenIds.contains { screenDescriptor($0, matches: card.screenId) })
        }
    }

    private func visualItems(for card: StaticContentCard) -> [StaticVisualReference] {
        module.visuals.filter { visual in
            card.visualIds.contains(visual.visualId)
                || visual.screenId == card.screenId
                || screenDescriptor(visual.screenId, matches: card.screenId)
        }
    }

    private func screenDescriptor(_ descriptor: String, matches screenId: String) -> Bool {
        let normalizedDescriptor = descriptor
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: ";", with: " ")

        return normalizedDescriptor
            .split(whereSeparator: { $0.isWhitespace })
            .contains { String($0).trimmingCharacters(in: .punctuationCharacters) == screenId }
    }

    private func initializeExpandedGroupsIfNeeded() {
        guard !didInitializeGroups else {
            return
        }

        expandedGroupIDs = Set(learningGroups.filter(\.isExpandedByDefault).map(\.id))
        didInitializeGroups = true
    }

    private var learningGroups: [LearningGroup] {
        var groups: [LearningGroup] = []
        var indexesByTitle: [String: Int] = [:]

        for card in module.cards {
            let title = groupTitle(for: card)

            if let index = indexesByTitle[title] {
                groups[index].cards.append(card)
            } else {
                let group = LearningGroup(
                    moduleId: module.moduleId,
                    title: title,
                    cards: [card],
                    isExpandedByDefault: groups.isEmpty
                )
                indexesByTitle[title] = groups.count
                groups.append(group)
            }
        }

        return groups
    }

    private var visibleSectionAudioQueue: [StaticAudioItem] {
        var queuedAudio: [StaticAudioItem] = []
        var queuedAudioIDs: Set<String> = []

        for group in learningGroups where expandedGroupIDs.contains(group.id) {
            for card in group.cards {
                guard let sectionAudio = audioItems(for: card).first,
                      !queuedAudioIDs.contains(sectionAudio.audioId) else {
                    continue
                }

                queuedAudio.append(sectionAudio)
                queuedAudioIDs.insert(sectionAudio.audioId)
            }
        }

        return queuedAudio
    }

    private func updateSectionAudioQueue() {
        audioController.setSectionAudioQueue(visibleSectionAudioQueue, contextID: module.moduleId)
    }

    @ViewBuilder
    private func learningGroupSection(_ group: LearningGroup) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Button {
                if expandedGroupIDs.contains(group.id) {
                    expandedGroupIDs.remove(group.id)
                } else {
                    expandedGroupIDs.insert(group.id)
                }
            } label: {
                HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .rotationEffect(.degrees(expandedGroupIDs.contains(group.id) ? 90 : 0))
                        .foregroundStyle(MPTTheme.secondaryText)
                        .animation(.easeInOut(duration: 0.15), value: expandedGroupIDs.contains(group.id))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("\(group.cards.count) \(group.cards.count == 1 ? "section" : "sections")")
                            .font(.caption)
                            .foregroundStyle(MPTTheme.secondaryText)
                    }

                    Spacer(minLength: MPTTheme.Spacing.small)
                }
                .padding(MPTTheme.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MPTTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator).opacity(0.35))
                )
            }
            .buttonStyle(.plain)
            .accessibilityHint("Expands or collapses this learning group.")

            if expandedGroupIDs.contains(group.id) {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    ForEach(group.cards, id: \.id) { card in
                        ExpandableContentCard(
                            card: card,
                            module: module,
                            sectionAudio: audioItems(for: card).first,
                            visuals: visualItems(for: card),
                            isCollapsible: false,
                            audioController: audioController,
                            initiallyExpanded: true
                        )
                    }
                }
            }
        }
    }

    private func groupTitle(for card: StaticContentCard) -> String {
        let title = card.title.lowercased()

        if title.hasPrefix("faq:") {
            return "FAQs / Common Questions"
        }

        if title.contains("important term") || title.hasPrefix("term:") || title.contains("important terms") {
            return "Important Terms"
        }

        switch module.title {
        case "About Tinnitus":
            return aboutTinnitusGroup(for: title)
        case "Sound Therapy":
            return soundTherapyGroup(for: title)
        case "Acceptance and Change":
            return acceptanceGroup(for: title)
        case "Mindfulness":
            return mindfulnessGroup(for: title)
        case "Distress Tolerance":
            return distressToleranceGroup(for: title)
        case "Cognitive Reframing":
            return cognitiveReframingGroup(for: title)
        case "Confidence and Communication":
            return confidenceCommunicationGroup(for: title)
        case "Sleep":
            return sleepGroup(for: title)
        case "My Plan":
            return myPlanGroup(for: title)
        default:
            return "Core Ideas"
        }
    }

    private func aboutTinnitusGroup(for title: String) -> String {
        if title.contains("body:") || title.contains("mind:") || title.contains("life:") {
            return "Body / Mind / Life"
        }
        if title.contains("multimodal") || title.contains("how to use") || title.contains("extra support") {
            return "Using This App"
        }
        if title.contains("pause") || title.contains("exploration") {
            return "Reflection and Exploration"
        }
        if title.contains("main points") || title.contains("next step") {
            return "Main Points / Takeaways"
        }
        return "Start Here: Why Tinnitus Is More Than Sound"
    }

    private func soundTherapyGroup(for title: String) -> String {
        if title.contains("masking") || title.contains("adaptation") || title.contains("sweet spot") || title.contains("volume") || title.contains("set the volume") {
            return "Masking, Habituation, and the Sweet Spot"
        }
        if title.contains("choosing") || title.contains("devices") || title.contains("during the day") || title.contains("at night") || title.contains("supports the rest") {
            return "Choosing Sounds and Devices"
        }
        if title.contains("sensitive") || title.contains("music speaker") || title.contains("hearing") {
            return "Sound Sensitivity and Hearing Care"
        }
        if title.contains("main points") || title.contains("before you move on") {
            return "Main Points / Takeaways"
        }
        if title.contains("why sound") || title.contains("restaurant") || title.contains("silence") {
            return "Why Sound Helps"
        }
        return "What Sound Therapy Is"
    }

    private func acceptanceGroup(for title: String) -> String {
        if title.contains("avoidance") || title.contains("eliminate") || title.contains("backfire") || title.contains("sound therapy shows") {
            return "Avoidance, Resistance, and Change"
        }
        if title.contains("yes and") || title.contains("two truths") || title.contains("tug-of-war") || title.contains("dropping the rope") {
            return "Yes AND and Tug-of-War"
        }
        if title.contains("reconnecting") || title.contains("mindset supports") {
            return "Reconnecting With What Matters"
        }
        if title.contains("practice:") || title.contains("step one") || title.contains("step two") {
            return "Putting It Into Practice"
        }
        if title.contains("main points") || title.contains("before you move on") {
            return "Main Points / Takeaways"
        }
        return "Acceptance Is Not Giving Up"
    }

    private func mindfulnessGroup(for title: String) -> String {
        if title.hasPrefix("guided practice:") {
            return "Guided Practices"
        }
        if title.contains("not forced") || title.contains("not the same") || title.contains("do not have to like") {
            return "What Mindfulness Is Not"
        }
        if title.contains("non-judgment") || title.contains("present") {
            return "Non-Judgment and Present-Moment Awareness"
        }
        if title.contains("sound therapy") || title.contains("supports acceptance") || title.contains("sound shifting") {
            return "Sound, Attention, and Tinnitus"
        }
        if title.contains("daily life") || title.contains("responding") || title.contains("3-2-1") || title.contains("listening") || title.contains("plan") {
            return "Mindfulness in Daily Life"
        }
        if title.contains("hard") || title.contains("tips") {
            return "When Mindfulness Feels Hard"
        }
        if title.contains("main points") {
            return "Main Points / Takeaways"
        }
        return "What Mindfulness Means"
    }

    private func distressToleranceGroup(for title: String) -> String {
        if title.contains("fluctuation") || title.contains("distress") || title.contains("panic") || title.contains("what you will learn") {
            return "What Distress Tolerance Is"
        }
        if title.contains("stop") || title.contains("tipp") || title.contains("temperature") || title.contains("paced breathing") || title.contains("paired muscle") || title.contains("intense movement") {
            return "STOP and TIPP"
        }
        if title.contains("ice cube") || title.contains("frozen orange") || title.contains("body") {
            return "Body-Based Reset Tools"
        }
        if title.contains("practice before") || title.contains("handle this moment") || title.contains("plan") {
            return "Practice Before Intense Moments"
        }
        if title.contains("main points") {
            return "Main Points / Takeaways"
        }
        return "What Distress Tolerance Is"
    }

    private func cognitiveReframingGroup(for title: String) -> String {
        if title.contains("thoughts") && title.contains("feelings") || title.contains("thoughts can move") || title.contains("challenging negative") {
            return "CBT and the Thoughts / Feelings / Behaviors Loop"
        }
        if title.contains("distortion") || title.contains("all-or-nothing") || title.contains("overgeneralization") || title.contains("filtering") || title.contains("mind reading") || title.contains("minimizing") || title.contains("catastrophizing") || title.contains("fallacies") || title.contains("labeling") || title.contains("personalization") {
            return "Distortion Library"
        }
        if title.contains("evidence") || title.contains("reframe") || title.contains("reality-checking") || title.contains("accurate thinking") || title.contains("example") {
            return "Evidence and Balanced Reframing"
        }
        if title.contains("start with") || title.contains("miss most") || title.contains("testing") || title.contains("plan") {
            return "Practice Expectations"
        }
        if title.contains("main points") || title.contains("connects") || title.contains("spread") {
            return "Main Points / Takeaways"
        }
        return "Reality-Checking Thoughts"
    }

    private func confidenceCommunicationGroup(for title: String) -> String {
        if title.contains("communicat") || title.contains("dear") || title.contains("man:") || title.contains("fast") || title.contains("speak up") || title.contains("self-advocacy") || title.contains("invisible symptoms") {
            return "Communicating With Others"
        }
        if title.contains("faq:") {
            return "FAQs / Common Questions"
        }
        if title.contains("self-critical") || title.contains("self-blame") || title.contains("inner voice") {
            return "The Self-Critical Voice"
        }
        if title.contains("self-compassion") || title.contains("validation") || title.contains("self-kindness") || title.contains("common humanity") || title.contains("mindful awareness") || title.contains("nickname") {
            return "Self-Compassion and Validation"
        }
        if title.contains("main points") || title.contains("plan") || title.contains("confidence inside") || title.contains("connects") {
            return "Main Points / Takeaways"
        }
        return "Supporting Yourself"
    }

    private func sleepGroup(for title: String) -> String {
        if title.hasPrefix("guided sleep practice:") {
            return "Guided Sleep Practices"
        }
        if title.contains("thought") || title.contains("myth") {
            return "Sleep Thoughts and Myths"
        }
        if title.contains("sleep drive") || title.contains("bed becomes") || title.contains("stimulus") || title.contains("cbt-i") {
            return "Sleep Drive and Stimulus Control"
        }
        if title.contains("sound at night") || title.contains("wind-down") || title.contains("environment") {
            return "Sound at Night"
        }
        if title.contains("sleep hygiene") || title.contains("schedule") || title.contains("stimulants") || title.contains("stress before bed") || title.contains("putting sleep") {
            return "Sleep Hygiene Foundations"
        }
        if title.contains("professional") || title.contains("seek help") {
            return "When to Seek Help"
        }
        if title.contains("practice:") || title.contains("main points") || title.contains("support plan") {
            return "Practice Tools and Takeaways"
        }
        return "Sleep and Tinnitus"
    }

    private func myPlanGroup(for title: String) -> String {
        if title.contains("three lines") || title.contains("reflection") {
            return "Three Lines Journal"
        }
        if title.contains("past entries") || title.contains("belongs") {
            return "Saved Practice Tools"
        }
        return "What My Plan Is"
    }
}

private struct LearningGroup: Identifiable {
    let moduleId: String
    let title: String
    var cards: [StaticContentCard]
    let isExpandedByDefault: Bool

    var id: String {
        let normalizedTitle = title
            .lowercased()
            .replacingOccurrences(of: " / ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
        return "\(moduleId)-\(normalizedTitle)"
    }
}

private struct ModuleHeaderAudioControl: View {
    let audio: StaticAudioItem
    @ObservedObject var audioController: AudioController

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Listen")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(MPTTheme.secondaryText)

                    Text(audio.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                Spacer()

                Button {
                    if isCurrentAudio && audioController.isPlaying {
                        audioController.togglePlayPause()
                    } else {
                        audioController.play(audio: audio)
                    }
                } label: {
                    Label(isCurrentAudioPlaying ? "Pause" : "Play", systemImage: isCurrentAudioPlaying ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            if isCurrentAudio, let statusMessage = audioController.statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .background(MPTTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.35))
        )
    }

    private var isCurrentAudioPlaying: Bool {
        isCurrentAudio && audioController.isPlaying
    }

    private var isCurrentAudio: Bool {
        audioController.currentAudioID == audio.audioId
    }
}

private struct ModuleSafetyScopeGroup: View {
    let safetyScopes: [StaticSafetyScope]
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                ForEach(safetyScopes, id: \.safetyScopeId) { safety in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(safety.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Text(safety.bodyMarkdown)
                            .font(.body)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.top, MPTTheme.Spacing.medium)
        } label: {
            HStack(spacing: MPTTheme.Spacing.medium) {
                Image(systemName: "exclamationmark.shield")
                    .foregroundStyle(MPTTheme.accentColor)
                Text("Safety and Scope")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
        .padding(MPTTheme.Spacing.large)
        .background(MPTTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.35))
        )
    }
}
