//
//  CheckInQuestionLibrary.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Foundation

struct CheckInQuestionLibrary: Equatable {
    let schemaVersion: String
    let timeWindow: String
    let scale: [CheckInScaleOption]
    let questions: [CheckInQuestion]

    static let empty = CheckInQuestionLibrary(
        schemaVersion: "onboarding_checkin_v1",
        timeWindow: "Over the past week",
        scale: [],
        questions: []
    )
}

struct CheckInQuestionLibraryLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    func loadLibrary() -> CheckInQuestionLibrary {
        guard let url = bundle.url(forResource: "onboarding_checkin_v1", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let document = try? decoder.decode(CheckInQuestionDocument.self, from: data) else {
            return .empty
        }

        return CheckInQuestionLibrary(
            schemaVersion: document.schemaVersion,
            timeWindow: document.timeWindow,
            scale: document.scale,
            questions: document.items
        )
    }
}
