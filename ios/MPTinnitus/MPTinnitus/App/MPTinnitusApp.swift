//
//  MPTinnitusApp.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI
import SwiftData

@main
struct MPTinnitusApp: App {
    private let localPersistenceController = LocalPersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootShellView()
                .task {
                    _ = localPersistenceController.validateContainer()

                    #if DEBUG
                    localPersistenceController.logInitializationStatus()
                    #endif
                }
        }
        .modelContainer(localPersistenceController.container)
    }
}
