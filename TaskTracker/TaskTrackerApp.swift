//
//  TaskTrackerApp.swift
//  TaskTracker
//
//  Created by Vipranan on 06/01/26.
//

import SwiftUI
import SwiftData

@main
struct TaskTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Task.self, User.self)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var authService: AuthenticationService?
    
    var body: some View {
        Group {
            if let authService = authService {
                if authService.isAuthenticated {
                    ContentView(authService: authService)
                } else {
                    LoginView(authService: authService)
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            if authService == nil {
                authService = AuthenticationService(modelContext: modelContext)
            }
        }
    }
}
