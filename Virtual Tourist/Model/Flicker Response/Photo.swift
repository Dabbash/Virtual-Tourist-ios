//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 25/07/2021.
//

import Foundation

struct Photos: Codable, Equatable {
    
    let phphp: String?
    
    
    enum CodingKeys: String, CodingKey {
        case phphp = ""
    }
}
