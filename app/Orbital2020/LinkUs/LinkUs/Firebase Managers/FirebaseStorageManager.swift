//
//  FirebaseStorageManager.swift
//  LinkUs
//
//  Created by macos on 21/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation
import FirebaseStorage

final class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    
    private let storage = Storage.storage().reference()
    
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /*
     /images/(uid)_profile_picture.png
    */
    
    // Uploads photo to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        // Store the image in Firebase Storage
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] metaData, error in
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                // Failed to upload image
                print("Failed to upload picture to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            // Successfully uploaded image to Firebase Storage
            
            // Get the url of the image
            strongSelf.storage.child("images/\(fileName)").downloadURL { (url, error) in
                
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                
                print("download url returned: \(urlString)")
                
                completion(.success(urlString))
                
            }
            
        }
        
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let reference = storage.child(path)
        
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        }
        
    }
    
    public enum StorageErrors: Error {
        
        case failedToUpload, failedToGetDownloadUrl
        
    }
    
    public func deleteProfilePicture(for path: String, completion: @escaping ((Bool) -> Void)) {
        
        let reference = storage.child(path)
        
        reference.delete { (error) in
            
            guard error == nil else {
                print("Error deleting profile picture")
                completion(false)
                return
            }
            
            print("Successfully deleted profile picture")
            completion(true)
            
        }
        
    }
    
}

