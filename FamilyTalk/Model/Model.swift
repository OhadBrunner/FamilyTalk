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
import SQLite3

extension Date {
    
    func toFirebase()->Double{
        return self.timeIntervalSince1970 * 1000
    }
    
    static func fromFirebase(_ interval:String)->Date{
        return Date(timeIntervalSince1970: Double(interval)!)
    }
    
    static func fromFirebase(_ interval:Double)->Date{
        if (interval>9999999999){
            return Date(timeIntervalSince1970: interval/1000)
        }else{
            return Date(timeIntervalSince1970: interval)
        }
    }
    
    var stringValue: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
}


class Model {
    
    static let instance = Model()
    
    lazy private var modelSQL:ModelSQL? = ModelSQL()
    lazy private var modelFirebase:ModelFirebase? = ModelFirebase()
    
    
    
    private init(){
    }
    
    
    
    func addMessage(msg: MessageModel){
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            
            switch msg.type {
                
            case .photo:
                let imageData = msg.content as! UIImage
                let time = "\(msg.timestamp)"
                
                saveImage(imageData: imageData, timeStamp: time) {
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
    
    ///////////////////////////////////////////////////////////////
    
    
    
    
    /*
     
     func getStudentById(id:String, callback:@escaping (Student)->Void){
     }
     
     func getAllStudents(callback:@escaping ([Student])->Void){ //asyncronic
     // get last update date from SQL
     let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSql?.database, table: Student.ST_TABLE)
     
     // get all updated records from firebase
     modelFirebase?.getAllStudents(lastUpdateDate, callback: { (students) in
     //update the local db
     print("got \(students.count) new records from FB")
     var lastUpdate:Date?
     for st in students{
     st.addStudentToLocalDb(database: self.modelSql?.database)
     if lastUpdate == nil{
     lastUpdate = st.lastUpdate
     }else{
     if lastUpdate!.compare(st.lastUpdate!) == ComparisonResult.orderedAscending{
     lastUpdate = st.lastUpdate
     }
     }
     }
     
     //upadte the last update table
     if (lastUpdate != nil){
     LastUpdateTable.setLastUpdate(database: self.modelSql!.database, table: Student.ST_TABLE, lastUpdate: lastUpdate!)
     }
     
     //get the complete list from local DB
     let totalList = Student.getAllStudentsFromLocalDb(database: self.modelSql?.database)
     
     //return the list to the caller
     callback(totalList)
     })
     }
     
     func getAllStudentsAndObserve(){
     // get last update date from SQL
     let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSql?.database, table: Student.ST_TABLE)
     
     // get all updated records from firebase
     modelFirebase?.getAllStudentsAndObserve(lastUpdateDate, callback: { (students) in
     //update the local db
     print("got \(students.count) new records from FB")
     var lastUpdate:Date?
     for st in students{
     st.addStudentToLocalDb(database: self.modelSql?.database)
     if lastUpdate == nil{
     lastUpdate = st.lastUpdate
     }else{
     if lastUpdate!.compare(st.lastUpdate!) == ComparisonResult.orderedAscending{
     lastUpdate = st.lastUpdate
     }
     }
     }
     
     //upadte the last update table
     if (lastUpdate != nil){
     LastUpdateTable.setLastUpdate(database: self.modelSql!.database, table: Student.ST_TABLE, lastUpdate: lastUpdate!)
     }
     
     //get the complete list from local DB
     let totalList = Student.getAllStudentsFromLocalDb(database: self.modelSql?.database)
     
     //return the list to the observers using notification center
     NotificationCenter.default.post(name: Notification.Name(rawValue:
     notifyStudentListUpdate), object:nil , userInfo:["students":totalList])
     })
     }
     */
    
    
    
    func saveImage(imageData: UIImage, timeStamp: String, callback:@escaping (String?)->Void){
        //1. save image to Firebase
        let image = UIImageJPEGRepresentation((imageData), 0.5)
        let child = UUID().uuidString
        MessageModel.saveMessageImageToFirebase(imageData: image!, child: child) {
            (path) in
            if path != nil {
                //2. save image localy
                self.saveImageToFile(image: imageData, name: timeStamp)
            }
            //3. notify the user on complete
            callback(path)
        }
    }
    
    
    func getImage(message: MessageModel, callback:@escaping (Bool)-> Void){
        //1. try to get the image from local store
        let localImageName = "\(message.timestamp)"
        if let image = self.getImageFromFile(name: localImageName){
            message.image = image
            //print("from local")
            callback(true)
        }else{
            //2. get the image from Firebase
            //print("from firebase")
            MessageModel.downloadImage(message: message) {
                (state) in
                if state == true {
                    //3. save the image localy
                    let image = message.image
                    let time = "\(message.timestamp)"
                    self.saveImageToFile(image: image!, name: time)
                }
                callback(true)
            }
        }
    }
    
    private func saveImageToFile(image: UIImage, name:String){
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            //print(filename)
            try? data.write(to: filename)
        }
    }
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func getImageFromFile(name:String)->UIImage?{
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile:filename.path)
    }
    
}



