//
//  ImageListViewModel.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/27/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ImageListViewModelInputs {
    func didSelect(index: IndexPath)
    var reloader: PublishSubject<Void> { get }
}

protocol ImageListViewModelOutputs {
    var photos: Driver<[FlickrPhotoModel]> { get }
    var loading: Driver<Bool> { get }
}

protocol ImageListViewModelType {
    var inputs: ImageListViewModelInputs { get }
    var outputs: ImageListViewModelOutputs { get }
}

class ImageListViewModel:ImageListViewModelType,ImageListViewModelOutputs,ImageListViewModelInputs {

    var inputs: ImageListViewModelInputs { self }
    var outputs: ImageListViewModelOutputs { self }
    
    struct Dependencies {
        let api = FlickAPIService()
    }
    
    var dependencies:Dependencies
    
    init(_ dependencies:Dependencies) {
        self.dependencies = dependencies
        let loading = ActivityIndicator()
        self.loading = loading.asSharedSequence(onErrorJustReturn: false)
        photos = self.reloader
            .asObservable()
            .flatMap { _ in
                dependencies.api.getImages().catchErrorJustReturn([]).trackActivity(loading)
            }.asDriver(onErrorJustReturn: [])
    }
    
    // MARK: Inputs
    var reloader = PublishSubject<Void>()
    
    func didSelect(index: IndexPath) {
        photos.asObservable()
            .map { $0[index.row] }
            .subscribe(onNext: { app.router.pushFlickPhoto($0) })
            .dispose()
    }
    
    // MARK: Outputs
    var photos:Driver<[FlickrPhotoModel]> = Driver<[FlickrPhotoModel]>.just([])
    
    var loading: Driver<Bool>
}
