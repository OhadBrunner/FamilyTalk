//
//  UserFirebase.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension UserModel {
    
    
    //MARK: Methods
    static func registerUser(withName: String, email: String, password: String, profilePic: UIImage, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                let storageRef = Storage.storage().reference().child("usersProfilePics").child(user!.uid)
                let imageData = UIImageJPEGRepresentation(profilePic, 0.1)
                storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                    if err == nil {
                        let path = metadata?.downloadURL()?.absoluteString
                        let values = ["name": withName, "email": email, "profilePicLink": path!]
                        Database.database().reference().child("users").child((user?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                            if errr == nil {
                                completion(true)
                            }
                        })
                    }
                })
            }
            else {
                completion(false)
            }
        })
    }
    
    
    static func loginUser(withEmail: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    
    static func getCurrentUserID() -> String {
        
        let id = Auth.auth().currentUser?.uid as String!
        return id!
    }
    
    
    static func getUserProfilePic(forID: String, completion: @escaping (UIImage) -> Void) {
        
        let storageRef = Storage.storage().reference().child("usersProfilePics").child(forID)
        storageRef.getData(maxSize: 10000000) {
            (data, error) in
            if (error == nil && data != nil){
                
                let image = UIImage(data: data!)
                completion(image!)
            }
        }
    }
    
}

