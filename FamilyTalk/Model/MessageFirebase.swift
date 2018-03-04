//
//  MessageFirebase.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//


import Foundation
import Firebase

extension MessageModel {
    
    
    class func downloadAllMessages(completion: @escaping (MessageModel) -> Swift.Void) {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            let messageDB = Database.database().reference().child("Messages")
            
            messageDB.observe(.childAdded) {
                (snapshot) in
                
                
                let snapshotValue = snapshot.value as! [String : Any]
                
                let messageType = snapshotValue["type"] as! String
                var type = MessageType.text
                switch messageType {
                case "photo":
                    type = .photo
                default: break
                }
                let content = snapshotValue["content"] as! String
                let timestamp = snapshotValue["timestamp"] as! Int
                let fromID = snapshotValue["fromID"] as! String
                
                
                if fromID == currentUserID {
                    let message = MessageModel.init(type: type, content: content, owner: .receiver, fromID: fromID, timestamp: timestamp)
                    completion(message)
                }
                    
                else {
                    let message = MessageModel.init(type: type, content: content, owner: .sender, fromID: fromID, timestamp: timestamp)
                    completion(message)
                }
            }
        }
    }
    
    class func downloadImage(message: MessageModel, completion: @escaping (Bool) -> Swift.Void)  {
        if message.type == .photo {
            let imageLink = message.content as! String
            let imageURL = URL.init(string: imageLink)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    message.image = UIImage.init(data: data!)
                    completion(true)
                }
            }).resume()
        }
    }
    
    
    //    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void)  {
    //        if self.type == .photo {
    //            let imageLink = self.content as! String
    //            let imageURL = URL.init(string: imageLink)
    //            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
    //                if error == nil {
    //                    self.image = UIImage.init(data: data!)
    //                    completion(true, indexpathRow)
    //                }
    //            }).resume()
    //        }
    //    }
    
    
    class func saveMessageImageToFirebase(imageData: Data, child: String, completion: @escaping (String?) -> Void) {
        
        Storage.storage().reference().child("messagePics").child(child).putData(imageData, metadata: nil) {
            (metadata, error) in
            if error == nil {
                let path = metadata?.downloadURL()?.absoluteString
                completion(path)
            }
        }
    }
    
    class func saveMessageToFirebase(values: [String:Any], completion: @escaping (Bool) -> Swift.Void)  {
        
        Database.database().reference().child("Messages").childByAutoId().setValue(values) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfuly!")
            }
        }
        
    }
    
}

