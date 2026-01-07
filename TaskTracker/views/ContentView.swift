//
//  ContentView.swift
//  TaskTracker
//
//  Created by Vipranan on 06/01/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var taskCount: Int = 0
    @Query private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    @State private var newTaskTitle = ""
    @State private var showingProfile = false
    
    let authService: AuthenticationService
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with user info and logout
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome back,")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(authService.currentUser?.username ?? "User")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                Text("Task Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                HStack{
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        addTask()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTaskTitle.isEmpty)
                    
                }
                .padding(.horizontal)
                
                // Task Statistics
                HStack(spacing: 20) {
                    VStack {
                        Text("\(tasks.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(tasks.filter { $0.isCompleted }.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(tasks.filter { !$0.isCompleted }.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("Pending")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // List of tasks
                List {
                    ForEach(tasks) { task in
                        HStack{
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                                .font(.title3)
                            
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                                .foregroundColor(task.isCompleted ? .secondary : .primary)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleTask(task)
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(authService: authService)
        }
    }
    
    private func addTask() {
        let newTask = Task(title: newTaskTitle)
        modelContext.insert(newTask) // save it to the database
        print("Added task \(newTaskTitle)") // debug output
        newTaskTitle = ""
    }
    
    private func toggleTask(_ task: Task) {
        withAnimation(.easeInOut(duration: 0.2)) {
            task.isCompleted.toggle()
        }
    }
    
    // deletes the task by swiping left
    private func deleteTask(at offsets: IndexSet){
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}

struct ProfileView: View {
    let authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Profile Header
                VStack(spacing: 15) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text(authService.currentUser?.username ?? "User")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(authService.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Profile Info
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Last Login:")
                        Spacer()
                        Text(formatDate(authService.currentUser?.lastLoginDate))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "person.badge.key")
                            .foregroundColor(.blue)
                        Text("Account Status:")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    authService.logout()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Sign Out")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView(authService: AuthenticationService(modelContext: ModelContext(try! ModelContainer(for: User.self))))
}
