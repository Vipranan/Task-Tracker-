//
//  AuthenticationService.swift
//  TaskTracker
//
//  Created by Kiro on 07/01/26.
//

import Foundation
import SwiftData
import CryptoKit

@Observable
class AuthenticationService {
    var isAuthenticated = false
    var currentUser: User?
    var errorMessage: String?
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        checkAuthenticationStatus()
    }
    
    func login(email: String, password: String) {
        // Clear any previous error
        errorMessage = nil
        
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        // Hash the password for comparison
        let passwordHash = hashPassword(password)
        
        // Try to find user in database
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == email && user.passwordHash == passwordHash
            }
        )
        
        do {
            let users = try modelContext.fetch(descriptor)
            if let user = users.first {
                // Successful login
                user.isLoggedIn = true
                user.lastLoginDate = Date()
                currentUser = user
                isAuthenticated = true
                try modelContext.save()
            } else {
                // Check if user exists with different password
                let emailDescriptor = FetchDescriptor<User>(
                    predicate: #Predicate<User> { user in
                        user.email == email
                    }
                )
                let existingUsers = try modelContext.fetch(emailDescriptor)
                
                if existingUsers.isEmpty {
                    errorMessage = "No account found with this email"
                } else {
                    errorMessage = "Incorrect password"
                }
            }
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }
    
    func register(username: String, email: String, password: String, confirmPassword: String) {
        // Clear any previous error
        errorMessage = nil
        
        // Validation
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        // Check if user already exists
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == email
            }
        )
        
        do {
            let existingUsers = try modelContext.fetch(descriptor)
            if !existingUsers.isEmpty {
                errorMessage = "An account with this email already exists"
                return
            }
            
            // Create new user
            let passwordHash = hashPassword(password)
            let newUser = User(username: username, email: email, passwordHash: passwordHash)
            newUser.isLoggedIn = true
            newUser.lastLoginDate = Date()
            
            modelContext.insert(newUser)
            try modelContext.save()
            
            currentUser = newUser
            isAuthenticated = true
            
        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
        }
    }
    
    func logout() {
        currentUser?.isLoggedIn = false
        try? modelContext.save()
        currentUser = nil
        isAuthenticated = false
    }
    
    private func checkAuthenticationStatus() {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.isLoggedIn == true
            }
        )
        
        do {
            let loggedInUsers = try modelContext.fetch(descriptor)
            if let user = loggedInUsers.first {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            print("Failed to check authentication status: \(error)")
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}