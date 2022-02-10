//
//  StudentLocation.swift
//  OntheMap2
//
//  Created by Mac on 11/6/21.
//

import Foundation

struct StudentLocation: Codable {
    
    let objectId: String
    let uniqueKey: String?
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let updatedAt: String
    let ACL: String?
    
    init(objectId: String, uniqueKey: String?, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, createdAt: String, updatedAt: String, ACL: String?) {
       self.objectId = objectId
       self.uniqueKey = uniqueKey
       self.firstName = firstName
       self.lastName = lastName
       self.mapString = mapString
       self.mediaURL = mediaURL
       self.latitude = latitude
       self.longitude = longitude
       self.createdAt = createdAt
       self.updatedAt = updatedAt
       self.ACL = ACL
  }
}
