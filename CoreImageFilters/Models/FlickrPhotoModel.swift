//
//  FlickrPhotoModel.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/27/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import Foundation

struct FlickrPhotoModel:Decodable {
    let id:String
    let secret:String
    let server:String
    let farm:Int
    let title:String
    
    var titleFixed:String {
        title.isEmpty ? "No title" : title
    }
    var imageURL:URL? {
        flickrImageURLFrom(self)
    }
}
