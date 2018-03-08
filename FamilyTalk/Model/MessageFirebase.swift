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
    
    
    static func downloadAllMessages(_ lastUpdateDate:Date?, completion: @escaping ([MessageModel]) -> Void) {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            
            let handler = {(snapshot:DataSnapshot) in
                var items = [MessageModel]()
                for child in snapshot.children.allObjects{
                    if let childData = child as? DataSnapshot{
                        if let snapshotValue = childData.value as? [String : Any] {
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
                                items.append(message)
                            }
                            else {
                                let message = MessageModel.init(type: type, content: content, owner: .sender, fromID: fromID, timestamp: timestamp)
                                items.append(message)
                            }
                        }
                    }
                }
                items.sort{ $0.timestamp < $1.timestamp }
                completion(items)
                }
        
        let ref = Database.database().reference().child("Messages")
        if (lastUpdateDate != nil){
            print("q starting at:\(lastUpdateDate!) \(lastUpdateDate!.toFirebase())")
            let fbQuery = ref.queryOrdered(byChild:"timestamp").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observeSingleEvent(of: .value, with: handler)
        }else{
            ref.observeSingleEvent(of: .value, with: handler)
            }
        }
    }

    static func downloadAllMessagesAndObserve(_ lastUpdateDate:Date?, completion:@escaping ([MessageModel])-> Void){
        print("FB: getAllStudentsAndObserve")
    
        if let currentUserID = Auth.auth().currentUser?.uid {
            //            let messageDB = Database.database().reference().child("Messages")
            //
            //            let handler = messageDB.observe(.childAdded) {
            //                (snapshot:DataSnapshot) in
            
            let handler = {(snapshot:DataSnapshot) in
                var items = [MessageModel]()
                for child in snapshot.children.allObjects{
                    if let childData = child as? DataSnapshot{
                        if let snapshotValue = childData.value as? [String : Any] {
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
                                let message = MessageModel.init(type: type, content: content, owner: .receiver, fromID: fromID, timestamp:  timestamp)
                                items.append(message)
                            }
                            else {
                                let message = MessageModel.init(type: type, content: content, owner: .sender, fromID: fromID, timestamp: timestamp)
                                items.append(message)
                            }
                        }
                    }
                }
                items.sort{ $0.timestamp < $1.timestamp }
                completion(items)
            }
        
            let ref = Database.database().reference().child("Messages")
        if (lastUpdateDate != nil){
            print("q starting at:\(lastUpdateDate!) \(lastUpdateDate!.toFirebase())")
            let fbQuery = ref.queryOrdered(byChild:"timestamp").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observe(DataEventType.value, with: handler)
        }else{
            ref.observe(DataEventType.value, with: handler)
        }
        }
    }
    
    
    static func clearObservers(){
        let ref = Database.database().reference().child("Messages")
        ref.removeAllObservers()
    }
    
    
    static func downloadImage(message: MessageModel, completion: @escaping (Bool) -> Void)  {
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
    
    
    static func saveMessageImageToFirebase(imageData: Data, child: String, completion: @escaping (String?) -> Void) {
        
        Storage.storage().reference().child("messagePics").child(child).putData(imageData, metadata: nil) {
            (metadata, error) in
            if error == nil {
                let path = metadata?.downloadURL()?.absoluteString
                completion(path)
            }
        }
    }
    
    static func saveMessageToFirebase(values: [String:Any], completion: @escaping (Bool) -> Void)  {
        
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

