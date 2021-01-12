//
//  ServicesResponce.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation

struct ServicesProfileResponse: Codable {
    let status: Bool
    let message: String?
    let data: [ServicesProfileDataResponse]?
}


struct ServicesProfileDataResponse: Codable {
    let advantages: String?
    let aralik1: String?
    let details: String?
    let id: String?
    let name: String?
    let phone: String?
    let image: String?
}
