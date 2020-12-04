//
//  StorageManager.swift
//  BamiSoro
//
//  Created by waheedCodes on 04/12/2020.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
}

extension StorageManager {
    
    public typealias uploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to Firbase Storage and returns the url in form of string for downloas
    public func uploadProfilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping uploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(
            data,
            metadata: nil,
            completion: { (storageMetadata, error) in
                guard error == nil else {
                    // Failed
                    print("Failed to upload data to Firbase Storage for picture.")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                
                self.storage.child("images/\(fileName)").downloadURL(completion: { (url, error) in
                    guard let url = url else {
                        print("Failed to get picture download url from Firebase")
                        completion(.failure(StorageErrors.failedToGetPictureDownloadURL))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    print("Profile picture download url: \(urlString)")
                    completion(.success(urlString))
                })
            })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetPictureDownloadURL
    }
}
