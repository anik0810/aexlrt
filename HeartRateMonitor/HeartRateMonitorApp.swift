//
//  HeartRateMonitorApp.swift
//  HeartRateMonitor
//
//  Created by Devangi Agarwal on 14/09/24.
//

import SwiftUI

@main
struct HeartRateMonitorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
