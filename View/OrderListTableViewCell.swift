//
//  OrderListTableViewCell.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/4/9.
//

import UIKit

class OrderListTableViewCell: UITableViewCell {

    @IBOutlet weak var coffeeImageView: UIImageView!
    @IBOutlet weak var ordererNameLabel: UILabel!
    @IBOutlet weak var coffeeNameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var coffeeQuantityLabel: UILabel!
    @IBOutlet weak var coffeePriceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
