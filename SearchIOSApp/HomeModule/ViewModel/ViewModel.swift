//
//  ViewModel.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation
import RxSwift

enum VCViewModelOutPut {
    case showProgress(loading: Bool)
    case refreshData
    case showError(message: String)
}

protocol VCViewModel {
//    var vmPassSubject: PublishSubject<VCViewModelOutPut> {get}
    var bindClosure: ((VCViewModelOutPut) -> Void)? {get set}
    var searchString: String? {get set}
    func search()
    func pullToRefresh()
    func nextPage()
    var cellCount: Int {get}
    func cellViewModel(for indexPath: IndexPath) -> CellViewModel
}


class VCViewModelImpl: VCViewModel {
    
    var bindClosure: ((VCViewModelOutPut) -> Void)?
    var searchString: String? {
        didSet {
            if searchString?.count ?? 0 >= 3  {
                reset()
                search()
            }
        }
    }
    
    var pageSize: Int = 9
    var pageNumber: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
//    let vmPassSubject: PublishSubject<VCViewModelOutPut>
    private var cellViewModels: [CellViewModel] {
        didSet {
            bindClosure?(.refreshData)
//            vmPassSubject.onNext(.refreshData)
        }
    }
    
    let dataStore: GitHubDataStore
    
    init(dataStore: GitHubDataStore){
        self.dataStore = dataStore
//        vmPassSubject =  PublishSubject<VCViewModelOutPut>()
        cellViewModels = []
    }
    
    
    var cellCount: Int  {
        return cellViewModels.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> CellViewModel {
        return cellViewModels[indexPath.row]
    }

    
    func viewDidLoad() {
        
    }
    
    func search() {
        if (isLastPage || isLoading) { return }
        isLoading = true
        bindClosure?(.showProgress(loading: true))
//        vmPassSubject.onNext(.showProgress(loading: true))
        dataStore.fetchUsers(search: searchString ?? "", pageNumber: pageNumber, pageSize: pageSize) {[weak self] response in
            guard let self = self else {return}
            self.isLoading = false
            self.bindClosure?(.showProgress(loading: false))
//            self.vmPassSubject.onNext(.showProgress(loading: false))
            switch response {
            case .success(let profiles):
                self.manageFetchedProfiles(profiles: profiles)
            case .failure( let error):
                self.bindClosure?(.showError(message: error.message))
//                self.vmPassSubject.onNext(.showError(message: error.message))
            }
        }
    }
    
    func manageFetchedProfiles(profiles: [ProfileModel]){
        if profiles.count < self.pageSize {
            self.isLastPage = true
        }
        
        cellViewModels = cellViewModels + profiles.map{.init(profile: $0)}
    }
    
    func pullToRefresh() {
        reset()
        search()
    }
    
    func reset() {
        pageNumber = 1
        cellViewModels = []
    }
    
    func nextPage() {
        if !isLastPage && !isLoading {
            pageNumber += 1
            search()
        }
    }
    
}
