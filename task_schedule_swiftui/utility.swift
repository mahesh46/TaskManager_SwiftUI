//
//  utility.swift
//  task_schedule_swiftui
//
//  Created by mahesh lad on 16/12/2023.
// issue on delete

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var taskTitle = ""
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("New Task")) {
                        TextField("Task Title", text: $taskTitle)
                        DatePicker("Scheduled Date", selection: $selectedDate, in: Date()...)
                    }

                    Section {
                        Button("Add Task") {
                            taskManager.addTask(title: taskTitle, scheduledDate: selectedDate)
                            taskTitle = ""
                        }
                    }
                }

                List {
                    Section(header: Text("Tasks")) {
                        ForEach(taskManager.tasks) { task in
                            TaskRow(task: task, toggleTaskCompletion: { taskManager.toggleTaskCompletion(task: task) })
                        }
                        .onDelete { indexSet in
                            taskManager.deleteTasks(at: indexSet)
                        }
                    }

                    Section {
                        Button("Delete Completed Tasks") {
                            taskManager.deleteCompletedTasks()
                        }
                    }
                }
            }
            .navigationTitle("Task Manager")
            .onAppear {
                taskManager.loadTasksFromCoreData()
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    var toggleTaskCompletion: () -> Void

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                .onTapGesture {
                    toggleTaskCompletion()
                }

            VStack(alignment: .leading) {
                Text(task.title)
                Text("Scheduled on: \(formattedDate(task.scheduledDate))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



