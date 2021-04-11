//
//  Order.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/4/9.
//

import Foundation

struct OrderRecords: Codable {
    var records: [CoffeeOrder]
}

struct CoffeeOrder: Codable {
    var id: String
    var fields: OrderData
    var createdTime: String
}

struct PostCoffeeOrder: Codable {
    var fields: OrderData
}

struct OrderData: Codable {
    var Name: String
    var Coffee: String
    var Price: Int
    var Size: String
    var Quantity: Int
}



struct DeleteData: Codable {
    var daleted: Bool
}
