//
//  RegisterResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation

struct RegisterResponse: Codable {
    let status: Bool
    let message: String
    let data: RegisterDataResponse?
}

struct RegisterDataResponse: Codable {
    let token: String?
    let user_id: Int?
}
