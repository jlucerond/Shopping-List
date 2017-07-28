//
//  GroceryItemModelController.swift
//  Shopping List
//
//  Created by Joe Lucero on 7/28/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation

class GroceryItemModelController {
    static let shared = GroceryItemModelController()
    
    func addNewGroceryItem(name: String, inCategory category: String?) {
        let _ = GroceryItem(name: name, category: category)
        saveToCoreData()
    }
    
    func delete(groceryItem: GroceryItem) {
        groceryItem.managedObjectContext?.delete(groceryItem)
        saveToCoreData()
    }
    
    func changeToggleOn(groceryItem: GroceryItem) {
        groceryItem.isPurchased = !groceryItem.isPurchased
        saveToCoreData()
    }
    
    func saveToCoreData() {
        do {
            try CoreDataStack.context.save()
        } catch {
            print("Error while saving.")
        }
    }
}
