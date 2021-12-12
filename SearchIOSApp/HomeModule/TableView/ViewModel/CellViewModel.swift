//
//  CellViewModel.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation


struct CellViewModel {
    private let profile: ProfileModel
    
    init(_ profile: ProfileModel){
        self.profile = profile
    }
    
    var name: String {
        profile.name
    }
    
    var type: String {
        profile.type
    }
    
    var avatar: URL {
        profile.imageURL
    }
}
