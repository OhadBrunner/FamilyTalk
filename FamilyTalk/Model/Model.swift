//
//  Model.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//


import Foundation
import UIKit
import Firebase


class ModelNotificationBase<T>{
    var name:String?
    
    init(name:String){
        self.name = name
    }
    
    func observe(callback:@escaping (T?)->Void)->Any{
        return NotificationCenter.default.addObserver(forName: NSNotification.Name(name!), object: nil, queue: nil) { (data) in
            if let data = data.userInfo?["data"] as? T {
                callback(data)
            }
        }
    }
    
    func post(data:T){
        NotificationCenter.default.post(name: NSNotification.Name(name!), object: self, userInfo: ["data":data])
    }
}

class ModelNotification{
    
    static let messagesList = ModelNotificationBase<[MessageModel]>(name: "messagesListNotificatio")
    static let Message = ModelNotificationBase<MessageModel>(name: "MessageNotificatio")
    
    static func removeObserver(observer:Any){
        NotificationCenter.default.removeObserver(observer)
    }
}


class Model {
    
    static let instance = Model()
    
    lazy private var modelSQL:ModelSQL? = ModelSQL()
    
    private init(){
    }
    
    func clear(){
        print("Model.clear")
        MessageModel.clearObservers()
    }
    
    func addMessage(msg: MessageModel){
        if let currentUserID = Auth.auth().currentUser?.uid {
            switch msg.type {
            case .photo:
                let imageData = msg.content as! UIImage
                let time = "\(msg.timestamp)"
                ModelFileStore.saveImage(imageData: imageData, timeStamp: time) {
                    (path) in
                    let values = ["type": "photo", "content": path!, "fromID": currentUserID, "timestamp": msg.timestamp] as [String : Any]
                    MessageModel.saveMessageToFirebase(values: values, completion: {(_) in
                    })
                }
            case .text:
                let values = ["type": "text", "content": msg.content, "fromID": currentUserID, "timestamp": msg.timestamp] as [String : Any]
                MessageModel.saveMessageToFirebase(values: values, completion: {(_) in
                })
            }
        }
        //save locally
        msg.addMessageToLocalDb(database: self.modelSQL?.database)
    }
    
    
    func getAllMessages(callback:@escaping ([MessageModel])->Void){
        print("Model.getAllMessages")
        
        // get last update date from SQL
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSQL?.database, table: MessageModel.MSG_TABLE)
        
        // get all updated records from firebase
        MessageModel.downloadAllMessages(lastUpdateDate) { (messages) in
            //update the local db
            print("got \(messages.count) new records from FB")
            var lastUpdate:Date?
            for ms in messages{
                ms.addMessageToLocalDb(database: self.modelSQL?.database)
                if lastUpdate == nil{
                    let date = Date.fromFirebase(Double(ms.timestamp))
                    lastUpdate = date
                }else{
                    if lastUpdate!.compare(lastUpdate!) == ComparisonResult.orderedAscending{
                        let date = Date.fromFirebase(Double(ms.timestamp))
                        lastUpdate = date
                    }
                }
            }
            
            //upadte the last update table
            if (lastUpdate != nil){
                LastUpdateTable.setLastUpdate(database: self.modelSQL!.database, table: MessageModel.MSG_TABLE, lastUpdate: lastUpdate!)
            }
            
            //get the complete list from local DB
            let totalList = MessageModel.getAllMessagesFromLocalDb(database: self.modelSQL?.database)
            
            //return the list to the caller
            callback(totalList)
        }
    }
    
    func getAllMessagesAndObserve(){
        print("Model.getAllStudentsAndObserve")
        // get last update date from SQL
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSQL?.database, table: MessageModel.MSG_TABLE)
        
        // get all updated records from firebase
        MessageModel.downloadAllMessagesAndObserve(lastUpdateDate) { (messages) in
            //update the local db
            print("got \(messages.count) new records from FB")
            var lastUpdate:Date?
            for ms in messages{
                ms.addMessageToLocalDb(database: self.modelSQL?.database)
                if lastUpdate == nil{
                    let date = Date.fromFirebase(Double(ms.timestamp))
                    lastUpdate = date
                }else{
                    if lastUpdate!.compare(lastUpdate!) == ComparisonResult.orderedAscending{
                        let date = Date.fromFirebase(Double(ms.timestamp))
                        lastUpdate = date
                    }
                }
            }
            
            //upadte the last update table
            if (lastUpdate != nil){
                LastUpdateTable.setLastUpdate(database: self.modelSQL!.database, table: MessageModel.MSG_TABLE, lastUpdate: lastUpdate!)
            }
            
            //get the complete list from local DB
            let totalList = MessageModel.getAllMessagesFromLocalDb(database: self.modelSQL?.database)
            print("\(totalList)")
            
            ModelNotification.messagesList.post(data: totalList)
        }
    }
    
}



