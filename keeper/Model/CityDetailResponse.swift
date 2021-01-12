//
//  CityDetailResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation


struct CityDetailResponse: Codable {
    let status: Bool
    let message: String?
    let data: [CityDataResponse]?
}


struct CityDataResponse: Codable {
    let id: String?
    let il_adi: String?
}


   
