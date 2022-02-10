//
//  PostLocation.swift
//  OntheMap2
//
//  Created by Mac on 11/6/21.
//

import Foundation

struct PostLocation: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
