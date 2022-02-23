//
//  DatabaseManager.swift
//  MessangerProject
//
//  Created by Nathaniel Whittington on 2/23/22.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
   
    
}

//MARK: - Account Management
extension DatabaseManager{
    
    
    public func userExists(with email:String, completion:@escaping((Bool)->Void)){
        
        
        database.child(email).observeSingleEvent(of: .value) { (DataSnapshot) in
            guard (DataSnapshot.value as? String) != nil else {
                completion(false)
                return}
        }
        
        completion(true)
    }
    
    
    ///inserts new user to database
    public func insertUser(with user: ChatAppUser){
        
        database.child(user.emailAddress).setValue([
            
            "first_name" : user.firstName,
            "last_name" : user.lastName
        
        ])
        
    }
    
}

struct ChatAppUser {
    let firstName : String
    let lastName : String
    let emailAddress : String
}
