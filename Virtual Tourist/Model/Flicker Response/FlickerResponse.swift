//
//  FlickerResponse.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 25/07/2021.
//

import Foundation

struct FlickerResponse: Codable {
    let stat: String
    let photos: PhotosResponse
}

struct PhotosResponse : Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo:[Photos]
}
