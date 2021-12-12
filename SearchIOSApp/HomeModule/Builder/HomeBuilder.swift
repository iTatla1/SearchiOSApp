//
//  HomeBuilder.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation
import UIKit
import Moya

struct HomeBuilder {
    func build() -> UIViewController {
        let viewController = UIStoryboard(.main).instantiate(ViewController.self)
        viewController.viewModel = VCViewModelImpl(dataStore: GitHubDataStoreImpl(provider: MoyaProvider<GitHub>()))
        let navController = UINavigationController()
        navController.setViewControllers([viewController], animated: true)
        return navController
    }
}
