//
//  Item.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 11/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
