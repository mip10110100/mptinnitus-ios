//
//  StaticModuleLibraryLoader.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation

struct StaticModuleLibraryLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    func loadLibrary() -> StaticModuleLibrary {
        guard let url = bundle.url(forResource: "module_library_v1", withExtension: "json") else {
            return StaticModuleLibrary(
                schemaVersion: "0.0.0",
                sourceFiles: [],
                modules: [],
                issues: [
                    StaticModuleLibraryIssue(
                        severity: .warning,
                        message: "module_library_v1.json is missing from the app bundle."
                    )
                ]
            )
        }

        do {
            let data = try Data(contentsOf: url)
            let document = try decoder.decode(StaticModuleLibraryDocument.self, from: data)
            return StaticModuleLibrary(
                schemaVersion: document.schemaVersion,
                sourceFiles: document.sourceFiles,
                modules: document.modules,
                issues: validate(document.modules)
            )
        } catch {
            return StaticModuleLibrary(
                schemaVersion: "0.0.0",
                sourceFiles: [],
                modules: [],
                issues: [
                    StaticModuleLibraryIssue(
                        severity: .error,
                        message: "module_library_v1.json could not be decoded: \(error.localizedDescription)"
                    )
                ]
            )
        }
    }

    private func validate(_ modules: [StaticModule]) -> [StaticModuleLibraryIssue] {
        var issues: [StaticModuleLibraryIssue] = []
        let moduleIds = Set(modules.map(\.moduleId))

        for module in modules {
            for link in module.relatedModules where !moduleIds.contains(link.moduleId) {
                issues.append(
                    StaticModuleLibraryIssue(
                        severity: .warning,
                        message: "\(module.moduleId) links to missing module \(link.moduleId)."
                    )
                )
            }
        }

        #if DEBUG
        print(
            "[MPTinnitus][StaticModuleLibrary] Loaded modules=\(modules.count), cards=\(modules.reduce(0) { $0 + $1.cards.count }), audio=\(modules.reduce(0) { $0 + $1.audio.count }), exercises=\(modules.reduce(0) { $0 + $1.exercises.count }), issues=\(issues.count)"
        )
        #endif

        return issues
    }
}
