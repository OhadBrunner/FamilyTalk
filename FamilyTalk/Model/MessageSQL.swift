//
//  MessageSQL.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//


import Foundation
import UIKit
import SQLite3

extension MessageModel {
    
    
    static let MSG_TABLE = "MESSAGES"
    static let MSG_TIME_STAMP = "TIME_STAMP"
    static let MSG_TYPE = "TYPE"
    static let MSG_CONTENT = "CONTENT"
    static let MSG_FROM_ID = "FROM_ID"
    static let MSG_LAST_UPDATE = "LAST_UPDATE"
    
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + MSG_TABLE + " ( " + MSG_TIME_STAMP + " TEXT PRIMARY KEY, "
            + MSG_TYPE + " TEXT, "
            + MSG_CONTENT + " TEXT, "
            + MSG_FROM_ID + " TEXT, "
            + MSG_LAST_UPDATE + " DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    
    func addMessageToLocalDb(database:OpaquePointer?){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + MessageModel.MSG_TABLE
            + "(" + MessageModel.MSG_TIME_STAMP + ","
            + MessageModel.MSG_TYPE + ","
            + MessageModel.MSG_CONTENT + ","
            + MessageModel.MSG_FROM_ID + ","
            + MessageModel.MSG_LAST_UPDATE + ") VALUES (?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let values = self.toDictionary()
            
            let timeStamp = values["timeStamp"]?.cString(using: .utf8)
            let type = values["type"]?.cString(using: .utf8)
            let content = values["content"]?.cString(using: .utf8)
            let fromId = values["fromId"]?.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, timeStamp,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, type,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, content,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, fromId,-1,nil);
            
            if (lastUpdate == nil){
                lastUpdate = Date()
            }
            sqlite3_bind_double(sqlite3_stmt, 5, lastUpdate!.toFirebase());
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            } else {
                print("no success")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getAllMessagesFromLocalDb(database:OpaquePointer?)->[MessageModel]{
        var messages = [MessageModel]()
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from MESSAGES;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let timeStamp =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                let type =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
                let conent =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))
                let fromId =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))
                //let update =  Double(sqlite3_column_double(sqlite3_stmt,4))
                print("read from filter st: \(String(describing: timeStamp)) \(String(describing: type)) \(String(describing: conent))")
                
                let message = MessageModel(_type: type!, _content: conent!, _fromID: fromId!, _timestamp: timeStamp!)
                messages.append(message)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return messages
    }
    
}








