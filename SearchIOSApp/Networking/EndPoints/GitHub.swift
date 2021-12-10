//
//  GitHub.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Moya

enum GitHub {
    case searchUsers(query: String, page: Int, pageSize: Int)
}

extension GitHub: TargetType {
    var baseURL: URL {
        URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case  .searchUsers(_, _, _):
            return "/search/users"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchUsers(_, _, _):
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .searchUsers(query, page, pageSize):
            return .requestParameters(parameters: ["q": query, "page": page, "per_page": pageSize], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
