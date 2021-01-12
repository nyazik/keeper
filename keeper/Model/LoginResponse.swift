//
//  LoginResponse.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 4.01.2021.
//

import Foundation

struct LoginResponse: Codable {
    let status: Bool
    let message: String
    let data: LoginDataResponse?
}

struct LoginDataResponse: Codable {
    let token: String?
}
