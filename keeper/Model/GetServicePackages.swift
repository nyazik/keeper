//
//  getServicePackages.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation


struct GetServicePackages: Codable {
    let status: Bool
    let message: String?
    let data: GetServicePackagesAvailability?
}

struct GetServicePackagesAvailability: Codable {
    let available: [PackagesDataBuyable]?
    let buyable: [PackagesDataBuyable]?
}

struct PackagesDataBuyable: Codable {
    let amount: String?
    let day: String?
    let details: String?
    let id: String?
    let name: String?
    let price: String?
    let service_id: String?
    let available: Bool?
}

