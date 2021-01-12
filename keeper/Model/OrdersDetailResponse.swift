//
//  OrdersDetailResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation


struct OrdersDetailResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [OrdersDataResponse]?
}


struct OrdersDataResponse: Codable {
    let id: String?
    let name: String?
    let price: String?
    let amount: String?
    let day: String?
    let service_id: String?
    let details: String?
}


   
