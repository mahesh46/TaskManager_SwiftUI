//
//  Task.swift
//  task_schedule_swiftui
//
//  Created by mahesh lad on 16/12/2023.
//

import Foundation

struct Task: Identifiable {
    let id: String
    let title: String
    let scheduledDate: Date
    var isCompleted: Bool = false
}
