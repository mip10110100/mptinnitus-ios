//
//  ManifestDebugLogger.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import Foundation

#if DEBUG
enum ManifestDebugLogger {
    static func log(_ snapshot: ManifestSnapshot) {
        let counts = snapshot.debugCounts
        print(
            """
            [MPTinnitus][ManifestLoader] Loaded counts: routes=\(counts.routes), screens=\(counts.screens), sections=\(counts.sections), audio=\(counts.audioItems), visuals=\(counts.visualItems), safetyScopes=\(counts.safetyScopes), soundSamples=\(counts.soundSamplePlaceholders), visualPlaceholders=\(counts.visualPlaceholders), issues=\(counts.issues)
            """
        )

        for issue in snapshot.issues {
            print("[MPTinnitus][ManifestLoader][\(issue.severity.rawValue)] \(issue.source): \(issue.message)")
        }
    }
}
#endif
