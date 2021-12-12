//
//  GitHubDataStore.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation
import Moya
import RxSwift

protocol GitHubDataStore {
    func fetchUsers(search: String, pageNumber: Int, pageSize: Int) -> Single<[ProfileModel]>
}


class GitHubDataStoreImpl: GitHubDataStore {
    let provider: MoyaProvider<GitHub>
    
    init(provider: MoyaProvider<GitHub>) {
        self.provider = provider
    }
    
    func fetchUsers(search: String, pageNumber: Int, pageSize: Int) -> Single<[ProfileModel]> {
        return provider.rx.request(.searchUsers(query: search, page: pageNumber, pageSize: pageSize))
            .catchConnectivityError()
            .flatMap { response in
                return try GitHubProfileMapper.map(response)
            }
    }
}
