//
//  ImageDetailViewModel.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/27/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import UIKit.UIImage
import RxSwift
import RxCocoa
import Kingfisher

protocol ImageDetailViewModelInputs {
    func didSelectFilter(_ index:Int)
}

protocol ImageDetailViewModelOutputs {
    var pickerItems: Observable<[String]> { get }
    var imageDriver:Driver<UIImage?> { get }
}

protocol ImageDetailViewModelType {
    var inputs: ImageDetailViewModelInputs { get }
    var outputs: ImageDetailViewModelOutputs { get }
}

class ImageDetailViewModel:ImageDetailViewModelType, ImageDetailViewModelOutputs, ImageDetailViewModelInputs {
    
    var inputs: ImageDetailViewModelInputs { return self }
    var outputs: ImageDetailViewModelOutputs { return self }
    
    struct Dependencies {
        enum FilterName {
            case none
            case filter(String)
            
            var name:String {
                if case .filter(let v) = self {
                    return v
                }
                return "None"
            }
        }
        let filterOperation:FilterApplyProtocol = FilterOperation()
        var filters = [.none] + CIFilter.filterNames(inCategory: "CICategoryBlur").map { FilterName.filter($0) }
    }
    private var dependencies:Dependencies
    private var flickrModel:FlickrPhotoModel
    
    
    var sourceImage:UIImage?
    let filterSubject:BehaviorSubject<UIImage?>
    
    var filterOperation:Disposable?
    let disposeBag = DisposeBag()
    
    init(_ model:FlickrPhotoModel, dependencies:Dependencies = Dependencies()) {
        self.dependencies = dependencies
        flickrModel = model
        pickerItems = Observable.of(dependencies.filters.map{ return $0.name })
        filterSubject = BehaviorSubject(value: sourceImage)
        
        imageDriver = filterSubject.asObservable().asDriver(onErrorJustReturn: nil)

        KingfisherManager.shared.retrieveImage(with: model.imageURL!, completionHandler: { [weak self] (result) in
            if case .success(let image) = result {
                self?.sourceImage = image.image
                self?.filterSubject.onNext(self?.sourceImage)
            }
        })
        
    }
    
    // MARK: Inputs
    
    func didSelectFilter(_ index: Int) {
        let filter = dependencies.filters[index]
        switch filter {
        case .none:
            filterSubject.onNext(sourceImage)
        case .filter(let name):
            filterOperation?.dispose()
            filterOperation = nil
            filterOperation = dependencies.filterOperation.applyFilter(to: sourceImage, filterName:name)
                .subscribe(onNext: { [weak self] in
                    self?.filterSubject.onNext($0)
                })
        }
    }
    
    
    // MARK: Outputs
    
    var imageDriver:Driver<UIImage?>
    
    var pickerItems: Observable<[String]>
    

    
}
