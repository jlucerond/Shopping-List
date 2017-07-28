//
//  GroceryItem.swift
//  Shopping List
//
//  Created by Joe Lucero on 7/28/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation
import CoreData

extension GroceryItem {
    convenience init(name: String,
                     category: String? = "No Category",
                     isPurchased: Bool? = false,
                     context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name

        if let category = category {
            self.category = category
        }
        
        if let isPurchased = isPurchased {
            self.isPurchased = isPurchased
        }
    }
}
