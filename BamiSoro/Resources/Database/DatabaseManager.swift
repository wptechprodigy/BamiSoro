//
//  DatabaseManager.swift
//  BamiSoro
//
//  Created by waheedCodes on 14/11/2020.
//

import Foundation
import Firebase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

// MARK: - Database Management

extension DatabaseManager {
    
    /// Check if user with email already exists
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        database.child(email).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
        
    }
    
    /// Inserts a new user into the database
    public func insertUser(with user: BamiSoroUser) {
        database.child(user.email).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}

// MARK: - A typical user model

struct BamiSoroUser {
    let firstName: String
    let lastName: String
    let email: String
    // let profilePicture: String
}
