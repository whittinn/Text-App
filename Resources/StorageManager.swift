//
//  StorageManager.swift
//  MessangerProject
//
//  Created by Nathaniel Whittington on 2/25/22.
//

import Foundation
import FirebaseStorage


class StoreManager {
    
    
    static let shared = StoreManager()
    private let storage = Storage.storage().reference()
    public typealias UploadPictureCompletion = (Result<String,Error>)->Void
   
    
    /*
     /images/afraz9-gmail.com_profile_picture.png
     */
    
    ///Uploads pictures to firebase storage and returns completion with url string download
    public func uploadProfilePictures(with data:Data, fileName:String, completion: @escaping UploadPictureCompletion){
        
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (StorageMetadata, error) in
            guard error == nil else {
                //failed
                
                completion(.failure(StorageErrors.failedToUpload))
                     
                
                
                
                
                return
            }
            
            let reference =  self.storage.child("images/\(fileName)").downloadURL { (URL, Error) in
                guard let url = URL else {
                    
                    print("")
                    completion(.failure(StorageErrors.failedToGetDownload))
                    return
                }
                
                let urlString = url.absoluteString
                print("downloaded url returned: \(urlString)")
                completion(.success(urlString))
            }
            
        }
        
        
    }
}

public enum StorageErrors : Error {
    
    case failedToUpload
    case failedToGetDownload
}
