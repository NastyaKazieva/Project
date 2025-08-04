//
//  ProjectApp.swift
//  Project
//
//  Created by Nastya Shlepakova on 17/07/2025.
//

import SwiftUI
import os

let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ToDoList", category: "General")

@main
struct ProjectApp: App {
    @StateObject private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ReminderListView(context: dataController.container.viewContext)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}
