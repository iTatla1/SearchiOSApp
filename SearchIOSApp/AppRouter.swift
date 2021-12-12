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
        return HomeBuilder().build()
    }
}


