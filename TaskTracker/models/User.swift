//
//  User.swift
//  TaskTracker
//
//  Created by Kiro on 07/01/26.
//

import Foundation
import SwiftData

@Model
class User {
    var id = UUID()
    var username: String
    var email: String
    var passwordHash: String
    var isLoggedIn: Bool = false
    var lastLoginDate: Date?
    
    init(username: String, email: String, passwordHash: String) {
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
    }
}