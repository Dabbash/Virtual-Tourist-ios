//
//  FlickerClient.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 25/07/2021.
//

import Foundation
import UIKit

class FlickerClient {
    static let apiKey = "b3cb2a01ce0e833482482de4a4b9e009"
    static let secret = "1571728a8b39425e"
    
    enum Endpoint {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let apiKeyParam = "&api_key=\(FlickerClient.apiKey)"
        
        case locationCoordinate(Double, Double)
        case photoURL(String, String, String)
        
        var stringValue: String {
            switch self {
            case .locationCoordinate(let lat, let lon):
                return Endpoint.base + "&lat=\(lat)" + "&lon=\(lon)" + "&per_page=18&format=json"
            case .photoURL(let serverId, let id, let secret):
                return "https://live.staticflickr.com/\(serverId)/\(id)_\(secret)_c.jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func fetchPhotos(lat: Double, lon: Double) {
        let url = Endpoint.locationCoordinate(lat, lon).url
        
//        var request = URLRequest(url: url)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error)
                return
            }
        
            
            let json = JSONDecoder()
            do {
                let response = try json.decode(FlickerResponse.self, from: data)
                print(response)
            } catch {
                print(error)
            }

            print(data)
        }
        
        task.resume()
        
    }
    
    
    
    
    
    
}
