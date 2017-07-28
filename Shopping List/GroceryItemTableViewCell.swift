//
//  GroceryItemTableViewCell.swift
//  Shopping List
//
//  Created by Joe Lucero on 7/28/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit

protocol GroceryItemTableViewCellDelegate: class {
    func cellWasTapped(_ cell: GroceryItemTableViewCell)
}

class GroceryItemTableViewCell: UITableViewCell {

    @IBOutlet weak var groceryNameLabel: UILabel!
    @IBOutlet weak var groceryIsPurchasedButton: UIButton!

    weak var delegate: GroceryItemTableViewCellDelegate?

    @IBAction func groceryCellWasTapped(_ sender: UIButton) {
        delegate?.cellWasTapped(self)
    }
    
    func updateView(with item: GroceryItem) {
        groceryNameLabel.text = item.name
        let image = item.isPurchased ? #imageLiteral(resourceName: "complete") : #imageLiteral(resourceName: "incomplete")
        groceryIsPurchasedButton.setImage(image, for: .normal)
    }
}
