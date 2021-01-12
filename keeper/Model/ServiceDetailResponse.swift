//
//  ServiceDetailResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation

struct ServicesDetailResponse: Codable {
    let status: Bool
    let message: String?
    let data: ServicesDataResponse?
}

struct ServicesDataResponse: Codable {
    let adress: String?
    let advantages: [String]?
    let aralik1: String?
    let category_id: String?
    let comments: [ServiceDetailComment]?
    let comments_count: Int?
    let details: String?
    let id: String?
    let image: String?
    let name: String?
    let phone: String?
    let banner: String?
    let comments_point_avg: Int?

}

struct ServiceDetailComment: Codable  {
    let date: String?
    let id: String?
    let mail: String?
    let puan: String?
    let service_id: String?
    let status: String?
    let text: String?
    let title: String?
}
