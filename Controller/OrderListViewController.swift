//
//  OrderListViewController.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/4/8.
//

import UIKit
private let reuseIdentifier = "OrderListTableViewCell"

class OrderListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var orderListTableView: UITableView!
    @IBOutlet weak var totalQuantityLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var mediumPrice: Int?
    var largePrice: Int?
    var extraLargePrice: Int?
    
    var urlStr = "https://api.airtable.com/v0/apphzzfdMDr480WN8/OrderData"
    var loadingActivityIndicator: UIActivityIndicatorView!
    var menuData:Array<Record> = []
    var orderCoffeeData = [CoffeeOrder]()

    var imageURLStr: String?
    override func viewDidLoad() {
        super.viewDidLoad()
         
        // Do any additional setup after loading the view.
        creatLoadingView()
        updateUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderCoffeeData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! OrderListTableViewCell
            
            let orderData = orderCoffeeData[indexPath.row].fields
            let ordererName = orderData.Name
            let coffeeName = orderData.Coffee
            let coffeeSize = orderData.Size
            let quantity = orderData.Quantity
            
            getCoffeeData(coffeeName: coffeeName)
            
            let orderPrice = getOrderPrice(coffeeSize: coffeeSize, coffeeQuantity: quantity)
            
            cell.coffeeNameLabel.text = coffeeName
            cell.ordererNameLabel.text = ordererName
            cell.coffeePriceLabel.text = orderPrice.description
            cell.coffeeQuantityLabel.text =
                quantity.description
            cell.sizeLabel.text = coffeeSize
            getImage(urlStr: imageURLStr) { image in
                cell.coffeeImageView.image = image
            }
            
            return cell
        }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let controller = UIAlertController(title: "確定要刪除嗎", message: "", preferredStyle: .alert)
            let okAtcion = UIAlertAction(title: "確定", style: .default) { (_) in
                let dataID = self.orderCoffeeData[indexPath.row].id
                print(dataID)
                self.deleteData(urlStr: self.urlStr, id: dataID) {
                   // print("dalete 76")
                    self.orderCoffeeData.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        
                        self.ititTotal()
                        tableView.deleteRows(at: [indexPath], with: .fade)
                       // print("deleteRow")
                    }
                }
                print("dalete 76")
                self.orderCoffeeData.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    
                    self.ititTotal()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print("deleteRow")
                }
                
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(okAtcion)
            controller.addAction(cancelAction)
            present(controller, animated: true)
        }
    }
    
    func updateUI() {
        print("fetch Data...")
        guard let data  = Record.readCoffeeDataFromFile() else { return  }
        menuData = data
        
        fetchData(urlstr: urlStr) { (orderData) in
            print("fetch success")
            guard let orderData = orderData else {return}
            self.orderCoffeeData = orderData
            DispatchQueue.main.async {
                print("enter main queue")
                self.loadingActivityIndicator.stopAnimating()
                self.ititTotal()
                self.orderListTableView.reloadData()
            }
        }
    }
    
    func getImage (urlStr: String?, completion: @escaping  (UIImage?) -> Void ) {
        
        if let urlStr = urlStr, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data,let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }else{
                    completion(nil)
                }
            }.resume()
        }
    }
    
    func creatLoadingView() {
        loadingActivityIndicator = UIActivityIndicatorView(style: .medium)
        loadingActivityIndicator.center = view.center
        view.addSubview(loadingActivityIndicator)
    }
    
    func ititTotal() {
        var totalPrice = 0
        var totalQuantity = 0
        
        orderCoffeeData.forEach { (CoffeeOrder) in
            totalQuantity += CoffeeOrder.fields.Quantity
        }
        
        if orderCoffeeData.count > 0 {
            for index in 0...(orderCoffeeData.count-1){
                getCoffeeData(coffeeName: orderCoffeeData[index].fields.Coffee)
                let coffeeSize = orderCoffeeData[index].fields.Size
                let coffeeQuantity = orderCoffeeData[index].fields.Quantity
                totalPrice += getOrderPrice(coffeeSize: coffeeSize, coffeeQuantity: coffeeQuantity)
            }
        }
        
        self.totalPriceLabel.text = totalPrice.description
        self.totalQuantityLabel.text = totalQuantity.description
    }
        
    func getCoffeeData(coffeeName: String) {
        menuData.forEach { (Record) in
            if coffeeName == Record.fields.Name{
                self.imageURLStr = Record.fields.Img.first?.url
                self.mediumPrice = Record.fields.Medium
                self.largePrice = Record.fields.Large
                guard let extraLargePrice = Record.fields.ExtraLarge
                else { return  }
                self.extraLargePrice = Record.fields.ExtraLarge
                 
            }
        }
    }

    
    func getCoffeePrice(coffeeSize: String) -> Int {
        var coffeePrice = 0
        if coffeeSize == "中杯"{
            coffeePrice = mediumPrice!
        }
        if coffeeSize == "大杯"{
            coffeePrice = largePrice!
        }
        else{
            coffeePrice = extraLargePrice!
        }
        return coffeePrice
    }
    
    func getOrderPrice(coffeeSize: String,coffeeQuantity: Int) -> Int {
        let coffeePrice = getCoffeePrice(coffeeSize: coffeeSize)
        let orderPrice = coffeePrice * coffeeQuantity
        return orderPrice
    }
    
    func fetchData(urlstr: String, completionHandler: @escaping ([CoffeeOrder]?) -> Void) {
        print("fetch Data.....")
        if let url = URL(string: urlStr) {
            loadingActivityIndicator.startAnimating()
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "Get"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response , error) in
                let decoder = JSONDecoder()
                if let data = data {
                    do{
                        let result = try? decoder.decode(OrderRecords.self, from: data)
                        let records = result!.records.sorted {
                            $0.createdTime < $1.createdTime
                        }
                        print("decode Success")
                        completionHandler(records)
                    } catch{
                        completionHandler(nil)
                        print("error 158")
                    }
                }
            }.resume()
        }
    }
    
    func deleteData(urlStr: String, id: String,completionHandler: @escaping () -> Void){
        print("Delete Data")
        let deleteUrlStr = urlStr + "/\(id)"
        if let url = URL(string: deleteUrlStr){
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let decoder = JSONDecoder()
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let data = data {
                    do { let dic = try? decoder.decode(DeleteData.self, from: data)
                        print(dic)
                       print("delete down")
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let row = orderListTableView.indexPathForSelectedRow?.row,
           let controller = segue.destination as? OrderTableViewController {
            controller.delegate = self
            
            let selectedOrderCoffeeData = self.orderCoffeeData[row]
            print(selectedOrderCoffeeData)
            let coffeeSize = selectedOrderCoffeeData.fields.Size
            let name = selectedOrderCoffeeData.fields.Name
            
            controller.updateOrderData = true
            controller.orderDataID = selectedOrderCoffeeData.id
            controller.ordererName = selectedOrderCoffeeData.fields.Name
            controller.selectedCoffeeName = selectedOrderCoffeeData.fields.Coffee
            
            controller.selectedSize = selectedOrderCoffeeData.fields.Size
            controller.totalPrize = selectedOrderCoffeeData.fields.Price
            controller.coffeeQuantity = selectedOrderCoffeeData.fields.Quantity
            
            
            
        }
        
        
    }
    
    
    
}
