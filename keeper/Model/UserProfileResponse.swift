//
//  UserProfileResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation

struct UserProfileResponse: Codable {
    let status: Bool
    let message: String?
    let data: UserProfileDataResponse?
}

struct UserProfileDataResponse: Codable {
    let id: String?
    let mail: String?
    let name: String?
    let phone: String?
    let image: String?
}
