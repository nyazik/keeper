//
//  AddressDetailResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation

struct AddressDetailResponse: Codable {
    let status: Bool
    let message: String?
    let data: [AddressDataResponse]?
}


struct AddressDataResponse: Codable {
    let details: String?
    let district_id: String?
    let id: String?
    let il_adi: String?
    let ilce_adi: String?
    let province_id: String?
    let title: String?
    let user_id: String?
}

