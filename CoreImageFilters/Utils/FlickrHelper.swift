//
//  FlickrHelper.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/27/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import Foundation

func flickrImageURLFrom(_ model:FlickrPhotoModel) -> URL? {
    let s = "https://farm\(model.farm).staticflickr.com/\(model.server)/\(model.id)_\(model.secret).jpg"
    return URL(string: s)
}
