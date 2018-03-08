//
//  ModelFilesStore.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 06/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//

import Foundation
import UIKit

class ModelFileStore {
    
    static func saveImage(imageData: UIImage, timeStamp: String, callback:@escaping (String?)->Void){
        //1. save image to Firebase
        let image = UIImageJPEGRepresentation((imageData), 0.5)
        let child = UUID().uuidString
        MessageModel.saveMessageImageToFirebase(imageData: image!, child: child) {
            (path) in
            if path != nil {
                //2. save image localy
                LocalFileStore.saveImageToFile(image: imageData, name: timeStamp)
            }
            //3. notify the user on complete
            callback(path)
        }
    }
    
    static func getImage(message: MessageModel, callback:@escaping (Bool)-> Void){
        //1. try to get the image from local store
        let localImageName = "\(message.timestamp)"
        if let image = LocalFileStore.getImageFromFile(name: localImageName){
            message.image = image
            callback(true)
        }else{
            //2. get the image from Firebase
            MessageModel.downloadImage(message: message) {
                (state) in
                if state == true {
                    //3. save the image localy
                    let image = message.image
                    let time = "\(message.timestamp)"
                    LocalFileStore.saveImageToFile(image: image!, name: time)
                }
                callback(true)
            }
        }
    }
    
}

