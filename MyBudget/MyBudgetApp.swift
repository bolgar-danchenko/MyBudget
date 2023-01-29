//
//  MyBudgetApp.swift
//  MyBudget
//
//  Created by Konstantin Bolgar-Danchenko on 29.01.2023.
//

import SwiftUI

@main
struct MyBudgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
