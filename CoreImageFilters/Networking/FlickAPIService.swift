//
//  FlickAPIService.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/26/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FlickAPIService {
    
    private var baseURLComponents:URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.flickr.com"
        urlComponents.path = "/services/rest"
        return urlComponents
    }
    private let apiKey = "0a48f7b362852e5e29226f1771d043ba"
    
    func getImages() -> Observable<[FlickrPhotoModel]>{
        let parameters = ["method": "flickr.photos.getRecent",
                          "api_key": apiKey,
                          "format": "json"]
        var urlComponents = baseURLComponents
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = urlComponents.url else {
            return Observable.just([])
        }
        let req = URLRequest(url: url)

        return URLSession.shared
            .rx.data(request: req)
            .retry(3)
            .map {
                self.parseImages($0)
            }
    }
    
    private func parseImages<T:Decodable>(_ data:Data) -> [T] {
        let text = String.init(data: data, encoding: .utf8)
        var cleanString = text?.replacingOccurrences(of: "jsonFlickrApi(", with: "")
        cleanString?.removeLast()
        if let d = cleanString?.data(using: .utf8) {
            let json = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String:AnyObject]
            guard let photos = json?["photos"] as? [String:AnyObject],
                let photo = photos["photo"] as? [AnyObject] else {
                    return []
            }
            do {
                let photoData = try JSONSerialization.data(withJSONObject: photo, options: .prettyPrinted)
                let models = try JSONDecoder().decode([T].self, from: photoData)
                return models
            } catch {
                print(error)
            }
        }
        return []
    }
    
}

