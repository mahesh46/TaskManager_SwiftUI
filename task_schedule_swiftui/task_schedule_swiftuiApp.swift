//
//  task_schedule_swiftuiApp.swift
//  task_schedule_swiftui
//
//  Created by mahesh lad on 15/12/2023.
//

import SwiftUI
import CoreData

@main
struct TaskManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Core Data setup
let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "TaskManager")
    container.loadPersistentStores { _, error in
        if let error = error {
            fatalError("Unresolved error \(error)")
        }
    }
    return container
}()
