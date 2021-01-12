//
//  ProvincesDetailResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation



struct ProvincesDetailResponse: Codable {
    let status: Bool
    let message: String
    let data: ProvincesDataResponse?
}


struct ProvincesDataResponse: Codable {
    let id: String?
    let il_id: String?
    let ilce_adi: String?
}


   
