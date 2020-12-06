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
    
    static func safeEmail(email: String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// MARK: - Database Management

/// Database manager (singleton: - for easy write and access)
extension DatabaseManager {
    
    /// Check if user with email already exists
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
        
    }
    
    /// Inserts a new user into the database
    public func insertUser(with user: BamiSoroUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to weite to the database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(
                of: .value,
                with: { snapshot in
                    // If the user collection has already been created
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        // TODO: - Check if user already exists - important when logging in with FB and Google
                        let newElement = [
                            "name": user.firstName + " " + user.lastName,
                            "safe_email": user.safeEmail
                        ]
                        // Append the user
                        usersCollection.append(newElement)
                        
                        self.database.child("users").setValue(usersCollection, withCompletionBlock: { (error, _) in
                            guard error == nil else {
                                print("Failed to add new user to the new collection")
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        })
                    } else {
                        let newElement = [
                            "name": user.firstName + " " + user.lastName,
                            "safe_email": user.safeEmail
                        ]
                        // create the user collection and insert the new user
                        let newCollection: [[String: String]] = [newElement]
                        
                        self.database.child("users").setValue(newCollection, withCompletionBlock: { (error, _) in
                            guard error == nil else {
                                print("Failed to add new user to the new collection")
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        })
                    }
                })
        })
    }
    
    /// Return all registered users
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}

// MARK: - A typical user model

struct BamiSoroUser {
    let firstName: String
    let lastName: String
    let email: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
