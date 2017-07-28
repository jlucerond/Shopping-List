//
//  ShoppingListTableViewController.swift
//  Shopping List
//
//  Created by Joe Lucero on 7/28/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {
    
    let resultsController: NSFetchedResultsController<GroceryItem> = {
        let request: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "isPurchased", ascending: true)
        let sort3 = NSSortDescriptor(key: "name", ascending: true)
        
        request.sortDescriptors = [sort1, sort2, sort3]
        
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: CoreDataStack.context,
                                          sectionNameKeyPath: "category",
                                          cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsController.delegate = self
        
        do {
            try resultsController.performFetch()
        } catch  {
            print("trouble loading the data")
        }
        
    }
    
    // IBAction
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add New Item",
                                                message: nil,
                                                preferredStyle: .alert)
        
        var groceryNameTextField: UITextField?
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Grocery Item"
            groceryNameTextField = textField
        }
        
        var groceryCategoryTextField: UITextField?
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Category"
            groceryCategoryTextField = textField
        }
        
        
        let addAction = UIAlertAction(title: "Add",
                                      style: .default) { (_) in
                                        guard let groceryName = groceryNameTextField?.text, !groceryName.isEmpty else { return }
                                        GroceryItemModelController.shared.addNewGroceryItem(name: groceryName, inCategory: groceryCategoryTextField?.text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - TableView Data Source Methods
extension ShoppingListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        let name = resultsController.sections?[section].name
        return name
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingItemCell", for: indexPath) as? GroceryItemTableViewCell else { return UITableViewCell() }
        
        let item = resultsController.object(at: indexPath)
        
        cell.delegate = self
        cell.updateView(with: item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = resultsController.object(at: indexPath)
            GroceryItemModelController.shared.delete(groceryItem: item) 
        }
    }
}

// MARK: - GroceryItemTableViewCellDelegate Methods
extension ShoppingListTableViewController: GroceryItemTableViewCellDelegate {
    func cellWasTapped(_ cell: GroceryItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let groceryItem = resultsController.object(at: indexPath)
        GroceryItemModelController.shared.changeToggleOn(groceryItem: groceryItem)
        cell.updateView(with: groceryItem)
    }
}

// MARK: - NSFetchedResultsControllerDelegate Methods
extension ShoppingListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // Deals with 1 object changing within 1 section
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Deals with the number of sections changing
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            // if error here, try replacing indexSet with [sectionIndex]
            let indexSet = IndexSet.init(integer: sectionIndex)
            tableView.deleteSections(indexSet, with: .automatic)
        case .insert:
            let indexSet = IndexSet.init(integer: sectionIndex)
            tableView.insertSections(indexSet, with: .automatic)
        default:
            return
        }
    }
    
}
