//
//  Category.swift
//  FamilyTalk
//
//  Created by Ohad Brunner on 11/03/2018.
//  Copyright © 2018 Ohad Brunner. All rights reserved.
//

import Foundation
import RealmSwift


class Category: Object {
    
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
