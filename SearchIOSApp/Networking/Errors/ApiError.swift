//
//  ApiError.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation

enum ApiError: Error {
    case connectivity, invalidData
    
    var message: String {
        switch self {
        case .connectivity:
            return "Failed to connect. Please check internet connection."
        case .invalidData:
            return "Some error occured. Please try again later."
        }
    }
}
