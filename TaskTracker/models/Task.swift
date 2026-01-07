//
//  Task.swift
//  TaskTracker
//
//  Created by Vipranan on 06/01/26.
//

import Foundation // for ides and task
import  SwiftData

@Model

class Task {
    
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    
    init( title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}
