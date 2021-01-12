//
//  PackageDetailResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation

struct PackageDetailResponse: Codable {
    let status: Bool
    let message: String?
    let data: PackageDataResponse?
}


struct PackageDataResponse: Codable {
    let id: String?
    let packet_id: String?
    let amount: String?
    let date_start: String?
    let date_end: String?
    let details: String?
    let status: String?
    let packet_name: String?
    let service_name: String?
}
