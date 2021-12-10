//
//  GitHubDataStore.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation
import Moya
import RxSwift

typealias FetchUserResponse = Result<[ProfileModel], ApiError>
typealias FetchUsersCompletion = (FetchUserResponse) -> Void
protocol GitHubDataStore {
    func fetchUsers(search: String, pageNumber: Int, pageSize: Int, completion: @escaping FetchUsersCompletion)
}


class GitHubDataStoreImpl: GitHubDataStore {
    let provider = MoyaProvider<GitHub>()
    let disposeBag = DisposeBag()
    
    func fetchUsers(search: String, pageNumber: Int, pageSize: Int, completion: @escaping FetchUsersCompletion) {
        provider.rx.request(.searchUsers(query: search, page: pageNumber, pageSize: pageSize)).subscribe { event in
            switch event {
            case .success(let response):
                completion(GitHubProfileMapper.map(response))
            case .failure( _):
                completion(.failure(.connectivity))
            }
        }
        .disposed(by: disposeBag)
    }
    
    private class GitHubProfileMapper {
        
        private init(){}
        
        static func map(_ response: Response) -> FetchUserResponse {
            if response.statusCode == 200, let root = try? JSONDecoder().decode(GitHubProfileRoot.self, from: response.data) {
                return .success(root.profileModels)
            }
            return .failure(ApiError.invalidData)
        }
        
        
        private struct GitHubProfileRoot: Decodable {
            private let items: [GitHubProfile]
            
            var profileModels: [ProfileModel] {
                items.map { $0.profileModel}
            }
            
            private struct GitHubProfile: Decodable {
                let loginName: String
                let avatar: URL
                let type: String
                
                private enum CodingKeys: String, CodingKey {
                    case loginName = "login"
                    case avatar = "avatar_url"
                    case type = "type"
                }
                
                var profileModel: ProfileModel {
                    ProfileModel(name: self.loginName, type: self.type, imageURL: self.avatar)
                }
            }
        }
        
    }
}

