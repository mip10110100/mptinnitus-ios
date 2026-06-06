//
//  CheckInScoring.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Foundation

enum CheckInScoring {
    static func responses(
        for questions: [CheckInQuestion],
        selections: [String: CheckInScaleSelection]
    ) -> [CheckInResponse] {
        questions.map { question in
            let rawValue = selections[question.id]?.responseValue
            let scoringValue = rawValue.map { value in
                question.isReverseScored ? Double(5 - value) : Double(value)
            }

            return CheckInResponse(
                questionId: question.id,
                value: rawValue,
                scoringValue: scoringValue
            )
        }
    }

    static func domainScores(
        questions: [CheckInQuestion],
        responses: [CheckInResponse]
    ) -> [CheckInDomainScore] {
        let questionsByID = Dictionary(uniqueKeysWithValues: questions.map { ($0.id, $0) })
        let responsesByDomain = Dictionary(grouping: responses) { response in
            questionsByID[response.questionId]?.domain
        }

        return CheckInDomain.allCases.map { domain in
            let values = responsesByDomain[domain, default: []].compactMap(\.scoringValue)
            let average = values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)

            return CheckInDomainScore(
                domain: domain,
                average: average,
                responseCount: values.count
            )
        }
    }

    static func trendMessages(
        latest: CheckInSession,
        previous: CheckInSession?
    ) -> [String] {
        guard let previous else {
            return []
        }

        let previousScores = Dictionary(uniqueKeysWithValues: previous.domainScores.map { ($0.domain, $0) })
        var messages: [String] = []

        for latestScore in latest.domainScores {
            guard let latestAverage = latestScore.average,
                  let previousAverage = previousScores[latestScore.domain]?.average else {
                continue
            }

            let difference = latestAverage - previousAverage
            let message = trendMessage(
                domain: latestScore.domain,
                difference: difference
            )
            messages.append(message)

            if messages.count == 3 {
                break
            }
        }

        return messages
    }

    private static func trendMessage(
        domain: CheckInDomain,
        difference: Double
    ) -> String {
        let threshold = 0.4

        if abs(difference) < threshold {
            return "\(domain.displayName) looks about the same."
        }

        if domain == .confidenceSelfCompassion {
            return difference < 0
                ? "Confidence looks stronger."
                : "Confidence may need more support this week."
        }

        return difference < 0
            ? "\(domain.displayName) looks a little better."
            : "\(domain.displayName) was higher this time."
    }
}
