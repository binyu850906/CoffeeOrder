//
//  CustomSelectionEnum.swift
//  CoffeeOrder
//
//  Created by binyu on 2021/4/6.
//

import Foundation

enum OrderInfo: CaseIterable {
    case orderer
    case size
}

enum Size: String, CaseIterable {
    case medium = "中杯"
    case large = "大杯"
    case extraLarge = "特大杯"
}

