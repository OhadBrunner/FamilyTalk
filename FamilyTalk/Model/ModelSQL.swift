//
//  ModelSQL.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 04/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//

import Foundation
import UIKit

extension String {
    public init?(validatingUTF8 cString: UnsafePointer<UInt8>) {
        if let (result, _) = String.decodeCString(cString, as: UTF8.self,
                                                  repairingInvalidCodeUnits: false) {
            self = result
        }
        else {
            return nil
        }
    }
}


class ModelSQL{
    var database: OpaquePointer? = nil
    
    init?(){
        let dbFileName = "database.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask).first{
            let path = dir.appendingPathComponent(dbFileName)
            
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return nil
            } else {
                print("work!")
            }
        }
        
        if MessageModel.createTable(database: database) == false{
            return nil
        }
        if LastUpdateTable.createTable(database: database) == false{
            return nil
        }
    }
    
}














