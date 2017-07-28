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
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: CoreDataStack.context,
                                          sectionNameKeyPath: nil,
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
        
        var myTextField: UITextField?
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Grocery Item"
            myTextField = textField
        }
        
        let addAction = UIAlertAction(title: "Add",
                                      style: .default) { (_) in
                                        guard let text = myTextField?.text, !text.isEmpty else { return }
                                        GroceryItemModelController.shared.addNewGroceryItem(name: text)
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
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return resultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingItemCell", for: indexPath) as? GroceryItemTableViewCell, let item = resultsController.fetchedObjects?[indexPath.row] else { return UITableViewCell() }
        
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
    
}
