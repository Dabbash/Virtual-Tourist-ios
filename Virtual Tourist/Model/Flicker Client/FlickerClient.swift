//
//  FlickerClient.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 25/07/2021.
//

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
                return Endpoint.base + Endpoint.apiKeyParam + "&lat=\(lat)" + "&lon=\(lon)" + "&per_page=18&format=json&nojsoncallback=1"
            case .photoURL(let server, let id, let secret):
                return "https://live.staticflickr.com/\(server)/\(id)_\(secret)_c.jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func fetchFlickerData(lat: Double, lon: Double, completionHandler: @escaping ([Photos], Error?) -> Void) {
        let url = Endpoint.locationCoordinate(lat, lon).url
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler([], error)
                }
                return
            }
            
            let json = JSONDecoder()
            do {
                let response = try json.decode(FlickerResponse.self, from: data)
                completionHandler(response.photos.photo, nil)
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    class func requestFlickerImage(server: String, id: String, secret: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        let url = Endpoint.photoURL(server, id, secret).url
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                completionHandler(data, error)
            }
        }
        
        task.resume()
    }
    
    
}
