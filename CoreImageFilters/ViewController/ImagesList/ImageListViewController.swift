//
//  ImageListViewController.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/26/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ImageListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    var viewModel:ImageListViewModelType
    
    init(viewModel: ImageListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
    }
    
    private func setupUI() {
        tableView.rowHeight = 80
        tableView.registerNib(cellType: ImageCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func bindViewModel() {
        
        Observable.of(rx.viewWillAppear, refreshControl.rx.controlEvent(.valueChanged)).merge()
            .asObservable()
            .bind(to: viewModel.inputs.reloader)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] in
                self?.tableView.deselectRow(at: $0, animated: true)
                self?.viewModel.inputs.didSelect(index: $0)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.loading.filter{ $0 == false }.drive(refreshControl.rx.isRefreshing).disposed(by: disposeBag)
        
        viewModel.outputs.photos
            .drive(tableView.rx.items(cellIdentifier: "ImageCell", cellType: ImageCell.self)) { (row, element, cell) in
                cell.titleLabel?.text = element.titleFixed
                cell.photoImageView?.kf.setImage(with: element.imageURL)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.photos
            .map( { "\($0.count) Images" })
            .drive(rx.title)
            .disposed(by: disposeBag)
    }


}


