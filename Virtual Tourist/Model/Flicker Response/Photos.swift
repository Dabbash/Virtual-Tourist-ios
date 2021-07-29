//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 25/07/2021.
//

import Foundation

struct Photos: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
