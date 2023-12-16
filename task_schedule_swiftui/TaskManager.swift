//
//  TaskManager.swift
//  task_schedule_swiftui
//
//  Created by mahesh lad on 16/12/2023.
//

import Foundation
import CoreData

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []

    func addTask(title: String, scheduledDate: Date) {
        let newTask = Task(id: UUID().uuidString, title: title, scheduledDate: scheduledDate)
        tasks.append(newTask)
        saveTaskToCoreData(task: newTask)
    }

    private func saveTaskToCoreData(task: Task) {
        let taskEntity = TaskEntity(context: persistentContainer.viewContext)
        taskEntity.id = task.id
        taskEntity.title = task.title
        taskEntity.scheduledDate = task.scheduledDate
        taskEntity.isCompleted = task.isCompleted

        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Error saving task to Core Data: \(error.localizedDescription)")
        }
    }

    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            
            // Update Core Data record
            updateTaskInCoreData(task: tasks[index])
        }
    }
    
    // Update a single task in Core Data
    private func updateTaskInCoreData(task: Task) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)

        do {
            let taskEntities = try persistentContainer.viewContext.fetch(fetchRequest)
            for entity in taskEntities {
                entity.isCompleted = task.isCompleted
            }
            try persistentContainer.viewContext.save()
        } catch {
            print("Error updating task in Core Data: \(error.localizedDescription)")
        }
    }

    func loadTasksFromCoreData() {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        do {
            let taskEntities = try persistentContainer.viewContext.fetch(fetchRequest)
            tasks = taskEntities.map { taskEntity in
                Task(
                    id: taskEntity.id ?? UUID().uuidString,
                    title: taskEntity.title ?? "",
                    scheduledDate: taskEntity.scheduledDate ?? Date(),
                    isCompleted: taskEntity.isCompleted
                )
            }
        } catch {
            print("Error fetching tasks from Core Data: \(error.localizedDescription)")
        }
    }

    // Delete completed tasks
    func deleteCompletedTasks() {
        tasks.removeAll(where: { $0.isCompleted })
        deleteCompletedTasksFromCoreData()
    }

    // Delete completed tasks from both in-memory array and Core Data
    func deleteCompletedTasksFromCoreData() {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCompleted == true")

        do {
            let completedTaskEntities = try persistentContainer.viewContext.fetch(fetchRequest)

            // Delete completed tasks in memory
            tasks.removeAll { task in
                completedTaskEntities.contains { $0.id == task.id }
            }

            // Delete completed tasks in Core Data
            for entity in completedTaskEntities {
                persistentContainer.viewContext.delete(entity)
            }

            try persistentContainer.viewContext.save()
        } catch {
            print("Error deleting completed tasks from Core Data: \(error.localizedDescription)")
        }
    }

    func deleteTasks(at offsets: IndexSet) {
        // Update Core Data to delete tasks
        for offset in offsets {
            guard offset < tasks.count else {
                continue // Skip invalid offsets
            }
            let task = tasks[offset]
            deleteTaskFromCoreData(task: task)
        }

        // Remove tasks from the in-memory array
        tasks.remove(atOffsets: offsets)
    }

        // Delete a single task from Core Data
        private func deleteTaskFromCoreData(task: Task) {
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)

            do {
                let taskEntities = try persistentContainer.viewContext.fetch(fetchRequest)
                for entity in taskEntities {
                    persistentContainer.viewContext.delete(entity)
                }
                try persistentContainer.viewContext.save()
            } catch {
                print("Error deleting task from Core Data: \(error.localizedDescription)")
            }
        }
}
