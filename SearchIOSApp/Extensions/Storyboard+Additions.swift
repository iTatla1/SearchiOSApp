//
//  Storyboard+Extension.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import UIKit

extension UIStoryboard {
    
    enum Name: String {
        case main   = "Main"
    }
    
    convenience init(_ name: Name, bundle: Bundle? = nil) {
        self.init(name: name.rawValue, bundle: bundle)
    }
    
    func instantiate<T: UIViewController>(_ type: T.Type) -> T {
        instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
}
