//
//  LoginResponse.swift
//  OntheMap2
//
//  Created by Mac on 11/6/21.
//

import Foundation

struct LoginResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let key: String?
    let registered: Bool
}

struct Session: Codable {
    let id: String?
    let expiration: String?
}
