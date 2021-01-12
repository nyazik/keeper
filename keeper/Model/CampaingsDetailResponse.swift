//
//  CampaignsDetailResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation


struct CampaingsDetailResponse: Codable {
    let status: Bool
    let message: String?
    let data: [CampaingsDataResponse]?
}


struct CampaingsDataResponse: Codable {
    let categories: String?
    let description: String?
    let id: String?
    let image: String?
    let title: String?
}


   
