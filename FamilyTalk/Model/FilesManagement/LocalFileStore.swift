//
//  LocalFileStore.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 06/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//

import Foundation
import UIKit

class LocalFileStore {

static func saveImageToFile(image: UIImage, name:String){
    if let data = UIImageJPEGRepresentation(image, 0.8) {
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        try? data.write(to: filename)
    }
}
    
static func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in:
        .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

static func getImageFromFile(name:String)->UIImage?{
    let filename = getDocumentsDirectory().appendingPathComponent(name)
    return UIImage(contentsOfFile:filename.path)
}

}
