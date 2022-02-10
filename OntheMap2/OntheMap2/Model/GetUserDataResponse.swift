//
//  GetUserDataResponse.swift
//  OntheMap2
//
//  Created by Mac on 11/6/21.
//

import Foundation

struct GetUserDataResponse: Codable {
    
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
