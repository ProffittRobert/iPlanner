//
//  Category.swift
//  iPlanner
//
//  Created by Robert Proffitt on 3/2/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class Category: Object
{
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}

