//
//  HomeBuilder.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation
import UIKit

struct HomeBuilder {
    func build() -> UIViewController {
        let viewController = UIStoryboard(.main).instantiate(ViewController.self)
        let navController = UINavigationController()
        navController.setViewControllers([viewController], animated: true)
        return viewController
    }
}
