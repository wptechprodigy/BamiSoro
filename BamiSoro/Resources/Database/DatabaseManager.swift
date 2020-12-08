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

// MARK: - Semd Messages/Conversation

extension DatabaseManager {
    // Schema for database conversation
    /*
        For each convo id
        yefncjkwcd -> [
            {
                "id": String
                "type": text, photo, audio, video
                "content": typeof type
                "date": Date()
                "sender_email": String
                "is_read": Bool
            }
         ]

        conversation -> [
            [
                "conversation_id": "yefncjkwcd"
                "other_user_email": String
                "latest_message": -> {
                    "date": Date()
                    "message": String
                    "is_read": Bool
                }
            ]
        ]
     */
    
    /// Creates a new conversation with target email and first message sent
    public func createNewConversation(with otherUseremail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(
            of: .value,
            with: { dataSnapshot in
                guard var userNode = dataSnapshot.value as? [String: Any] else {
                    completion(false)
                    print("User not found")
                    return
                }
                
                let messageDate = firstMessage.sentDate
                let dateString = ChatViewController.dateFormattre.string(from: messageDate)
                
                var message = ""
                
                switch firstMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(_):
                    break
                case .video(_):
                    break
                case .location(_):
                    break
                case .emoji(_):
                    break
                case .audio(_):
                    break
                case .contact(_):
                    break
                case .linkPreview(_):
                    break
                case .custom(_):
                    break
                }
                
                let conversationID = "conversation_\(firstMessage.messageId)"
                
                let newConversation: [String : Any] = [
                    "id": conversationID,
                    "other_user_email": otherUseremail,
                    "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                    ]
                ]
                
                if var conversations = userNode["conversations"] as? [[String: Any]] {
                    // Converstaion collection exists for this user
                    // Append a new conversation then
                    conversations.append(newConversation)
                    userNode["conversations"] = conversations
                    ref.setValue(
                        userNode,
                        withCompletionBlock: { [weak self] (error, _) in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            self?.finishCreatingConversation(conversationID: conversationID,
                                                            firstMessage: firstMessage,
                                                            completion: completion)
                        })
                    
                } else {
                    // Create a new conversation collection for the user
                    // Append a new conversation then
                    userNode["conversations"] = [
                        newConversation
                    ]
                    
                    ref.setValue(
                        userNode,
                        withCompletionBlock: { [weak self] (error, _) in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            self?.finishCreatingConversation(conversationID: conversationID,
                                                            firstMessage: firstMessage,
                                                            completion: completion)
                        })
                }
            })
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormattre.string(from: messageDate)
        
        var messageContent = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            messageContent = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": messageContent,
            "date": dateString,
            "sender_email": safeEmail,
            "is_read": false
        ]
        
        let value: [String: Any] = [
            "messages": [
                message
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    /// Fetch and return all conversation with target email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Fetch and returns the messages for a particular conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Send messages except for the first time message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
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
