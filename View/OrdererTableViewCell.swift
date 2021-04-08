//
//  OrdererTableViewCell.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/4/6.
//

import UIKit

class OrdererTableViewCell: UITableViewCell {

    @IBOutlet weak var ordererLabel: UILabel!
    @IBOutlet weak var ordererNameTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
