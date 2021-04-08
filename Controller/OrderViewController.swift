//
//  OrderViewController.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/4/6.
//

import UIKit

class OrderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    

    @IBOutlet weak var customSelectionTableView: UITableView!
    @IBOutlet weak var orderCoffeeImageView: UIImageView!
    @IBOutlet weak var orderCoffeeLabel: UILabel!
    @IBOutlet weak var orderCoffeeDescribeLabel: UILabel!
    @IBOutlet weak var orderQuantityLabel: UILabel!
    @IBOutlet weak var orderPriceLabel: UILabel!
    
    var menuData: Array<Record> = []
    var ordererName: String?
    var coffeeName: String!
    var coffeeDesrcibe: String?
    var size: String!
    var coffeePrice: Int?
    var mediumPrice: Int!
    var largePrice: Int?
    var extraLargePrice: Int?
    var coffeeQuantity = 1
    var drinkImageURL: String!
    var updateOrderData = false
    var orderDataID: String?
    
    var orderPrice: Int?
    var feedPrice = 0
    
    var sizeChecked = Array(repeating: false, count: Size.allCases.count)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    getCoffeeData()
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        OrderInfo.allCases.count
    }
   
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let orderInfoType = OrderInfo.allCases[section]
        
        switch orderInfoType {
        case .orderer:
            return ""
        case .size:
            return "容量"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let orderInfoType = OrderInfo.allCases[section]
        switch orderInfoType {
        case .orderer:
            return 1
        case .size :
            // 熟成檸果&墨玉歐特 只有中杯
            guard coffeeName == "氮氣冷萃咖啡" || coffeeName == "氮氣冷萃咖啡" || coffeeName == "經典特調氮氣冷萃咖啡" || coffeeName == "鹹焦糖風味綿雲氮氣冷萃咖啡" else { return Size.allCases.count }
            return Size.allCases.count - 1
       }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderInfoType = OrderInfo.allCases[indexPath.section]
        switch orderInfoType {
        case .orderer:
            let cell = customSelectionTableView.dequeueReusableCell(withIdentifier: "OrdererTableViewCell") as! OrdererTableViewCell
            cell.ordererLabel.text = "訂購人："
            cell.ordererNameTextField.placeholder = "請輸入你的小名"
            cell.ordererNameTextField.delegate = self
            guard let ordererName = ordererName else {
                return cell
            }
            cell.ordererNameTextField.text = ordererName
            return cell
        case .size:
            let cell = customSelectionTableView.dequeueReusableCell(withIdentifier: "OrderCoffeeTableViewCell") as! OrderCoffeeTableViewCell
            cell.addPriceLabel.isHidden = true
            cell.addFeedPriceLabel.isHidden = true
            cell.selectionLabel.text = Size.allCases[indexPath.row].rawValue
            if sizeChecked[indexPath.row] {
                cell.radioImageView.image = UIImage(named: "radio_on")
            }
           else{
            cell.radioImageView.image = UIImage(named: "radio_off")
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderInfoType = OrderInfo.allCases[indexPath.section]
        switch orderInfoType {
        case .orderer:
            return
        case .size:
            sizeChecked = Array(repeating: false, count: Size.allCases.count)
            sizeChecked[indexPath.row] = !sizeChecked[indexPath.row]
            size = Size.allCases[indexPath.row].rawValue
            if sizeChecked[indexPath.row] {
                if indexPath.row == 0 {
                    coffeePrice = mediumPrice
                }
                if indexPath.row == 1 {
                    coffeePrice = largePrice
                }
                if indexPath.row == 2 {
                    coffeePrice = extraLargePrice
                }
            }
           showOrderPrice()
        }
        tableView.reloadData()
    }
    
    func optionCheckForUpdateMode() {
        sizeChecked[Size.allCases.firstIndex(of: Size(rawValue: size)!)!] = true
    }
    
    func getCoffeeData() {
        guard let data = Record.readCoffeeDataFromFile() else { return }
        print("readDone")
        menuData = data
        guard let coffeeName = coffeeName
        else {return}
        menuData.forEach { (Record) in
            if coffeeName == Record.fields.Name{
                print("drinkName:\(coffeeName)")
                orderCoffeeLabel.text = coffeeName.description
                
                self.drinkImageURL = Record.fields.Img[0].url
                orderCoffeeImageView.image = nil
                
                if let urlStr = URL(string: self.drinkImageURL){
                    URLSession.shared.dataTask(with: urlStr) { (data, reesponse, error) in
                        if let data = data,
                           let image = UIImage(data: data){
                            DispatchQueue.main.async {
                                print{"imageDone"}
                                self.orderCoffeeImageView.image = image
                            }
                            
                        }
                    }.resume()
                }
                
                self.mediumPrice = Record.fields.Medium
                self.largePrice = Record.fields.Large
                guard let extraLargePrice = Record.fields.ExtraLarge else { return  }
                self.extraLargePrice = extraLargePrice
            }
        }
    
    }
    
    
    
    func showOrderPrice() {
        print("show Order Price")
        orderPrice = coffeePrice! * coffeeQuantity
        orderQuantityLabel.text = coffeeQuantity.description
        orderPriceLabel.text = orderPrice?.description
    }
    
    
    @IBAction func reduceCoffeeNumber(_ sender: Any) {
        if coffeeQuantity > 1 {
            coffeeQuantity -= 1
        } else{
            coffeeQuantity = 1
        }
        orderQuantityLabel.text = coffeeQuantity.description
        orderPriceLabel.text = orderPrice?.description
        showOrderPrice()
    }
    
    @IBAction func addCoffeeNumber(_ sender: Any) {
        coffeeQuantity += 1
        orderQuantityLabel.text = coffeeQuantity.description
        orderPriceLabel.text = orderPriceLabel.description
        showOrderPrice()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        ordererName = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

