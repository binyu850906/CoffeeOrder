//
//  DrinkMenu.swift
//  OrderAPP
//
//  Created by binyu on 2021/2/18.
//

import Foundation

struct ResponseData: Codable {
    let records: [Record]
}

struct Record: Codable {
    let id: String
    let fields: Field
    
    static func saveToFile(records: [Record]){
        print("Save Coffee Data")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(records) {
            let userDefault = UserDefaults.standard
            userDefault.setValue(data, forKey: "records")
        }
    }
 
    static func readCoffeeDataFromFile() ->[Record]?{
        print("read Coffee Data")
        let userDefault = UserDefaults.standard
        let decoder = JSONDecoder()
        if let data = userDefault.data(forKey: "records"),
           let records = try? decoder.decode([Record].self, from: data){
            return records
        }
        else{
            return nil
        }
    }
}

struct Field: Codable {
    let Medium: Int?
    let ExtraLarge: Int?
    let Large: Int
    let Name: String
    let Img: [DrinkImage]
    struct DrinkImage: Codable {
        let url: String
    }
}

