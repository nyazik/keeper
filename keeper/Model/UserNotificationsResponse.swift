//
//  UserNotificationsResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation


struct UserNotificationsResponse: Codable {
    let status: Bool
    let message: String?
    let data: [UserNotificationsDataResponse]?
}


struct UserNotificationsDataResponse: Codable {
    let id: String?
    let user_id: String?
    let title: String?
    let content: String?
    let date: String?
}


   
