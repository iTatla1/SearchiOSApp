//
//  PrimitiveSequence+ConnectivityError.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/12/21.
//

import Foundation
import RxSwift
import Moya 

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func catchConnectivityError() -> Single<Element> {
        return flatMap { response in
            guard 200..<300 ~= response.statusCode else {
                throw ApiError.connectivity
            }
            return .just(response)
        }
    }
}
