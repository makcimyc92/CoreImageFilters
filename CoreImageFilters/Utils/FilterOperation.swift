//
//  FilterOperation.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/27/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import RxSwift
import RxCocoa

protocol FilterApplyProtocol {
    func applyFilter(to inputImage: UIImage?, filterName:String) -> Observable<UIImage?>
}

class FilterOperation:FilterApplyProtocol {
    
    enum FilterError:Error {
        case preProccessing
        case applyFilter
    }
    
    func applyFilter(to inputImage: UIImage?, filterName:String) -> Observable<UIImage?> {
        return Observable<UIImage?>.create { observer in
            var isCancel = false
            DispatchQueue.global().async {
                let context = CIContext()
                guard let filter = CIFilter(name: filterName),
                    let img = inputImage,
                    let sourceImage = CIImage(image: img) else {
                        observer.onError(FilterError.preProccessing)
                        return
                }
                filter.setValue(sourceImage, forKey: kCIInputImageKey)
                guard  let output = filter.outputImage,
                    let cgimg = context.createCGImage(output, from: output.extent) else {
                        observer.onError(FilterError.applyFilter)
                        return
                }
                let processedImage = UIImage(cgImage: cgimg, scale: img.scale, orientation: img.imageOrientation)
                if !isCancel {
                    observer.onNext(processedImage)
                }
            }
            return Disposables.create {
                isCancel = true
            }
        }
    }
}
