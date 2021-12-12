//
//  AppRouterTest.swift
//  SearchIOSAppTests
//
//  Created by Muhammad Usman Tatla on 12/12/21.
//

import XCTest
@testable import SearchIOSApp

class AppRouterTest: XCTestCase {

    func test_appRouterTopVC_buildsHomeModule() {
        let viewController = AppRouter().getTopViewController()
        
        XCTAssertTrue(viewController is UINavigationController)
        XCTAssertTrue((viewController as? UINavigationController)?.viewControllers.first! is ViewController)
    }

}
