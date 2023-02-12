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
            DeviceIdiomView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
