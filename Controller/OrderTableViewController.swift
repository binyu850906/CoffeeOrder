//
//  OrderTableViewController.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/6/23.
//

import UIKit

class OrderTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var selectedCoffeeImageView: UIImageView!
    
    @IBOutlet weak var ordererTextField: UITextField!
    @IBOutlet weak var selectedCoffeeDescribeLabel: UILabel!
    @IBOutlet weak var selectedCoffeeNameLabel: UILabel!

    @IBOutlet weak var mediumSizeImageView: UIImageView!
    @IBOutlet weak var largeSizeImageView: UIImageView!
    @IBOutlet weak var extraLargeSizeImageView: UIImageView!
    @IBOutlet weak var totalCoffeePriceLabel: UILabel!
    @IBOutlet weak var coffeeQuantityLabel: UILabel!
    @IBOutlet weak var sendDataButton: UIButton!
    
    var selectedCoffeeName: String?
    var menuData: [Record] = []
    var selectedSizes: [Bool] = Array.init(repeating: false, count: 3)
    var selectedSize: String?
    var coffeePrice: Int? {
        didSet{
            if coffeePrice == 0 {
                totalCoffeePriceLabel.text = "暫不提供"
            }else {
                totalPrize = coffeePrice! * coffeeQuantity
                totalCoffeePriceLabel.text = totalPrize?.description
            }
            
        }
    }
    var totalPrize: Int? = 0
    var mediumPrice: Int?
    var largePrice: Int?
    var extraLargePrice: Int?
    var coffeeQuantity = 1
    var ordererName: String?
    
    var delegate: OrderListViewController?
    var orderDataID: String?
    
    var updateOrderData = false
    
    let apiKey = "keyNs8bjk9Yd8xlXw"
    let urlStr = "https://api.airtable.com/v0/apphzzfdMDr480WN8/OrderData"
    
    override func viewDidLoad() {
        super.viewDidLoad()

     getCoffeeData()
     updateUI()
    }

   
func getCoffeeData () {
    
    guard let data = Record.readCoffeeDataFromFile() else {return}
    print("ReadDone")
    menuData = data
    guard let selectedCoffeeName = selectedCoffeeName else {
        return
    }
    menuData.forEach { record in
        if selectedCoffeeName == record.fields.Name {
            print("coffeeName \(selectedCoffeeName)")
            selectedCoffeeNameLabel.text = selectedCoffeeName
            let selectedCoffeeDesrcibe = record.fields.Description
            let selectedcoffeeImageUrl = record.fields.Img.first?.url
            selectedCoffeeImageView.image = nil
            
            mediumPrice = record.fields.Medium
            largePrice = record.fields.Large
            if let extraLargePrice = record.fields.ExtraLarge {
                self.extraLargePrice = extraLargePrice
            }else {
                self.extraLargePrice = 0
            }
            
            if let selectedSize = selectedSize {
                switch selectedSize {
                
                case "中杯" :
                    selectedSizes[0] = true
                    mediumSizeImageView.image = UIImage(named: "radio_on")
                    coffeePrice = mediumPrice
                case "大杯" :
                    selectedSizes[1] = true
                    largeSizeImageView.image = UIImage(named: "radio_on")
                    coffeePrice = largePrice
                case "特大杯":
                    selectedSizes[2] = true
                    extraLargeSizeImageView.image = UIImage(named: "radio_on")
                    coffeePrice = extraLargePrice
                default:
                    return
                }
            }  else {
               coffeePrice = mediumPrice
            }
            
            
            
            
            if let imageUrl = URL(string: selectedcoffeeImageUrl!) {
                URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    if let data = data, let coffeeImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.selectedCoffeeImageView.image = coffeeImage
                            self.selectedCoffeeDescribeLabel.text = selectedCoffeeDesrcibe
                            self.totalCoffeePriceLabel.text = self.totalPrize?.description
                        }
                    }
                }.resume()
                
            }
            
            
        }
    }
}
    func updateUI () {
        
        if let ordererName = ordererName, let totalPrize = totalPrize {
            
            ordererTextField.text = ordererName
            coffeeQuantityLabel.text = coffeeQuantity.description
            totalCoffeePriceLabel.text = totalPrize.description
            
        }
        
        if updateOrderData {
            sendDataButton.setTitle("修改清單", for: .normal)
        }
        else {
            sendDataButton.setTitle("加入訂單", for: .normal)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        switch selectedRow {
        case 3 :
            selectedSizes[0].toggle()
            if selectedSizes[0] {
                coffeePrice = mediumPrice
                selectedSize = Size.allCases[0].rawValue
                mediumSizeImageView.image = UIImage(named: "radio_on")
                selectedSizes[1] = false
                selectedSizes[2] = false
                largeSizeImageView.image = UIImage(named: "radio_off")
                extraLargeSizeImageView.image = UIImage(named: "radio_off")
            }
        case 4 :
            selectedSizes[1].toggle()
            if selectedSizes[1] {
                coffeePrice = largePrice
                selectedSize = Size.allCases[1].rawValue
                largeSizeImageView.image = UIImage(named: "radio_on")
                selectedSizes[0] = false
                selectedSizes[2] = false
                mediumSizeImageView.image = UIImage(named: "radio_off")
                extraLargeSizeImageView.image = UIImage(named: "radio_off")
            }
        case 5:
            selectedSizes[2].toggle()
            if selectedSizes[2] {
                coffeePrice = extraLargePrice
                selectedSize = Size.allCases[2].rawValue
                extraLargeSizeImageView.image = UIImage(named: "radio_on")
                selectedSizes[0] = false
                selectedSizes[1] = false
                mediumSizeImageView.image = UIImage(named: "radio_off")
                largeSizeImageView.image = UIImage(named: "radio_off")
            }
        default:
            return
        }

    }

  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        ordererName = textField.text
    }
    @IBAction func addButtonPress(_ sender: Any) {
        coffeeQuantity += 1
        totalPrize = coffeePrice! * coffeeQuantity
        if totalPrize == 0 {
            totalCoffeePriceLabel.text = "暫不提供"
        }
        else{
            totalCoffeePriceLabel.text = totalPrize?.description
        }
        
        coffeeQuantityLabel.text = coffeeQuantity.description
        
    }
    
    @IBAction func reduseButtonPress(_ sender: Any) {
        coffeeQuantity -= 1
        if coffeeQuantity <= 0 {
            coffeeQuantity = 1
        }
        totalPrize = coffeePrice! * coffeeQuantity
        if totalPrize == 0 {
            totalCoffeePriceLabel.text = "暫不提供"
        }else{
            totalCoffeePriceLabel.text = totalPrize?.description
        }
        coffeeQuantityLabel.text = coffeeQuantity.description
    }
    
    func sentOrderRequest() {
        let orderData = OrderData(Name: ordererName!, Coffee: selectedCoffeeName!, Price: totalPrize!, Size: selectedSize!, Quantity: coffeeQuantity)
        
        let coffeeOrder = PostCoffeeOrder(fields: orderData)
        let url: URL?
        if updateOrderData{
            guard let id = orderDataID else {return}
            let updateURL = urlStr + "/\(id)"
            url = URL(string: updateURL)
        }else {
            url = URL(string: urlStr)
        }
        
        var urlRequest = URLRequest(url: url!)
        if updateOrderData{
            urlRequest.httpMethod = "PUT"
        }else{
            urlRequest.httpMethod = "POST"
        }
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        print("bulid jsonEncoder")
        if let data = try? jsonEncoder.encode(coffeeOrder) {
            print("try jsonEncoder")
            URLSession.shared.uploadTask(with: urlRequest, from: data) { redata, res, error in
                if let response = res as? HTTPURLResponse , response.statusCode == 200, error == nil {
                    print("success")
                }else {
                    print(error)
                }
            }.resume()
            
        }
    }
    
  
    @IBAction func sendDataButtonPress(_ sender: Any) {
        var addToOrderListButtonTitle: String!
        if sendDataButton.titleLabel?.text == "加入訂單" {
            addToOrderListButtonTitle = "加入訂單"
        }else {
            addToOrderListButtonTitle = "修改訂單"
        }
        let controller = UIAlertController(title: addToOrderListButtonTitle, message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            guard self.checkOption() else {
                return
            }
            self.sentOrderRequest()
            self.dismiss(animated: true) {
                self.delegate?.updateUI()
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(confirmAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    func checkOption() -> Bool {
    print(selectedSizes,ordererName)
        var check = false
        selectedSizes.forEach {
            size in
            guard size == true else {
                return
            }
            guard let _ = ordererName else {
                return
            }
            check = true
        }
        if check == false {
            let controller = UIAlertController(title: "", message: "資料填寫未完全", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(confirmAction)
            present(controller, animated: true, completion: nil)
        }
        return check
    }
    
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
