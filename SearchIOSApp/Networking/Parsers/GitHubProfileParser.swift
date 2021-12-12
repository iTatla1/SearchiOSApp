//
//  GitHubProfileParser.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/12/21.
//

import Foundation
import RxSwift
import Moya

final class GitHubProfileMapper {
    
    private init(){}
    
    static func map(_ response: Response) throws -> Single<[ProfileModel]> {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(GitHubProfileRoot.self, from: response.data) {
            return Single.create { single in
                single(.success(root.profileModels))
                return Disposables.create()
            }
        }
        throw ApiError.invalidData
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
