//
//  StudentLocationResults.swift
//  OntheMap2
//
//  Created by Mac on 11/6/21.
//

import Foundation

struct StudentLocationResults: Codable {
    let results: [StudentLocation]
    
    init(results: [StudentLocation]) {
        self.results = results
    }
}
