//
//  QuickBiteApp.swift
//  QuickBite
//
//  Created by Vu Phong on 19/10/25.
//

import SwiftUI

@main
struct QuickBiteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
