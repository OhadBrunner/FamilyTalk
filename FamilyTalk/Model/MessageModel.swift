//
//  MessageModel.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//


import Foundation
import UIKit
import Firebase
import CoreData

class MessageModel {
    
    //MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: Int
    var image: UIImage?
    //var imageURL: String? //FOR SQL
    var fromID: String
    var lastUpdate:Date?
    
    
    //MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner, fromID: String, timestamp: Int) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.fromID = fromID
    }
    
    init(_type: String, _content: String, _fromID: String, _timestamp: String) {
        
        fromID = _fromID
        
        let id = Auth.auth().currentUser?.uid as String!
        
        if id == fromID {
            owner = MessageOwner.sender
        } else {
            owner = MessageOwner.receiver
        }
        if _type == "text" {
            type = MessageType.text
        } else {
            type = MessageType.photo
        }
        content = _content as String
        
        timestamp = Int(_timestamp)!
    }
    
    
    
    func toDictionary() -> Dictionary<String,String> {
        
        let _type = "\(type)"
        let _content = "\(content)"
        let _timeStamp = "\(timestamp)"
        
        var values = Dictionary<String,String>()
        
        values["type"] = _type
        values["content"] = _content
        values["timeStamp"] = _timeStamp
        values["fromId"] = fromID
        
        return values
    }
    
    
    
    
}

