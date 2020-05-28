//
//  AppRouter.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/26/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import UIKit

final class AppRouter {
    var window: UIWindow?
    var rootNavigation:UINavigationController?
    
    func launchRootNavigation() {
        let dep = ImageListViewModel.Dependencies()
        let viewModel = ImageListViewModel(dep)
        let viewController = ImageListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        rootNavigation = navigationController
    }
    
    func pushFlickPhoto(_ photo:FlickrPhotoModel) {
        let viewModel = ImageDetailViewModel(photo)
        let vc = ImageDetailViewController(viewModel: viewModel)
        rootNavigation?.pushViewController(vc, animated: true)
    }

}
