//
//  ImageDetailViewController.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/27/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ImageDetailViewController: UIViewController {

    let disposeBag = DisposeBag()
    var viewModel:ImageDetailViewModelType
    
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var picker:UIPickerView!
    
    init(viewModel: ImageDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.outputs
            .pickerItems
            .bind(to: picker.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: disposeBag)
        
        viewModel.outputs
            .imageDriver
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)
        
        picker.rx.itemSelected
            .subscribe(onNext: { [viewModel] in
                viewModel.inputs.didSelectFilter($0.row)
            }).disposed(by: disposeBag)

    }
}
