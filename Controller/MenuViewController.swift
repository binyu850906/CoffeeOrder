//
//  MenuViewController.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/4/4.
//

import UIKit
private let reuseIdentifier = "MenuCollectionViewCell"

public let apiKey = "keyNs8bjk9Yd8xlXw"

class MenuViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var menuData: Array<Record> = []
    let urlStr = "https://api.airtable.com/v0/appZ1MCbtphNojnK2/OrderCoffee"
    
    @IBOutlet weak var menuCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setcell()
        
        fetchData(urlStr: urlStr) { (menuData) in
            guard let menuData = menuData
            else{return}
            
            Record.saveToFile(records: menuData)
        }
        // Do any additional setup after loading the view.
    }
    
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(menuData.count)
        return menuData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MenuCollectionViewCell
        cell.coffeeNameLabel.text = menuData[indexPath.item].fields.Name
        cell.coffeeImageView.image = nil
        if let imageUrl = URL(string: menuData[indexPath.item].fields.Img[0].url) {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.coffeeImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        return cell
    }
    
    func setcell() {
        menuCollectionViewFlowLayout.itemSize = CGSize(width: 115, height: 115)
        menuCollectionViewFlowLayout.estimatedItemSize = .zero
        menuCollectionViewFlowLayout.minimumInteritemSpacing = 1
        menuCollectionViewFlowLayout.minimumLineSpacing = 5
    }
    
    func fetchData(urlStr: String,completionHandler: @escaping([Record]?) -> Void) {
        print("fetch data...")
        let url = URL(string: urlStr)
        var urlRequset = URLRequest(url: url!)
        urlRequset.httpMethod = "Get"
        urlRequset.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequset) { (data, response, error) in
            let decoder = JSONDecoder()
            if let data = data{
                do {
                    let result = try decoder.decode(ResponseData.self, from: data)
                    print("decode success")
                    self.menuData = result.records
                    completionHandler(result.records)
                    DispatchQueue.main.async {
                        self.menuCollectionView.reloadData()
                    }
                } catch  {
                    print(error)
                }
            }
        }.resume()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? OrderTableViewController
        if let item = menuCollectionView.indexPathsForSelectedItems?.first?.item{
            controller?.selectedCoffeeName
                = menuData[item].fields.Name
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

}
