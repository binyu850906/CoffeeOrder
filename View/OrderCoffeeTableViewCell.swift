//
//  OrderCoffeeTableViewCell.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/4/6.
//

import UIKit

class OrderCoffeeTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var addPriceLabel: UILabel!
    @IBOutlet weak var addFeedPriceLabel: UILabel!
    @IBOutlet weak var radioImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
