//
//  AppRouter.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation
import UIKit

struct AppRouter {
    func getTopViewController() -> UIViewController {
        let viewController = UIStoryboard(.main).instantiate(ViewController.self)
        return viewController;
    }
}


