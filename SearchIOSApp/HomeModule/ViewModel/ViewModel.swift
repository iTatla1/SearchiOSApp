//
//  ViewModel.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation
import RxSwift
import RxCocoa

//enum VCViewModelOutPut {
//    case showProgress(loading: Bool)
//    case refreshData
//    case showError(message: String)
//}

protocol VCViewModel {
    var loaderSubject: PublishSubject<Bool> {get}
    var errorSubject: PublishSubject<String> {get}
    var cellModelObservalble: Observable<[CellViewModel]> {get}
    var searchString: String {get set}
    
    func pullToRefresh()
    func nextPage()
}


class VCViewModelImpl: VCViewModel {
    let loaderSubject: PublishSubject<Bool>
    let errorSubject: PublishSubject<String>
    var cellModelObservalble: Observable<[CellViewModel]> {
        modelsBehaviourRelay.asObservable()
    }
    var searchString: String {
        didSet {
                reset()
                search()
        }
    }
    
    private var pageSize: Int = 9
    private var pageNumber: Int = 1
    private var isLastPage: Bool = false
    private var loadingRelay = BehaviorRelay<Bool>(value:false)
    private let dataStore: GitHubDataStore
    private let disposeBag = DisposeBag()
    private let modelsBehaviourRelay: BehaviorRelay<[CellViewModel]>
    
    var isLoading: Bool {
        loadingRelay.value
    }
    
    init(dataStore: GitHubDataStore, loaderSubject: PublishSubject<Bool> = PublishSubject<Bool>(), errorSubject: PublishSubject<String> = PublishSubject<String>(), modelsBehaviour: BehaviorRelay<[CellViewModel]> = BehaviorRelay<[CellViewModel]>(value: [])){
        self.dataStore = dataStore
        self.loaderSubject = loaderSubject
        self.errorSubject = errorSubject
        self.modelsBehaviourRelay = modelsBehaviour
        self.searchString = ""
        
        loaderSubject.bind(to: loadingRelay).disposed(by: disposeBag)
    }

    
    func viewDidLoad() {
        
    }
    
    func search() {
        if (isLastPage || isLoading || searchString.isEmpty) { return }
        loaderSubject.onNext(true)
        dataStore.fetchUsers(search: searchString, pageNumber: pageNumber, pageSize: pageSize)
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] profiles in
                guard let self = self else {return}
                self.loaderSubject.onNext(false)
                self.manageFetchedProfiles(profiles: profiles)
            } onFailure: {[weak self]  error in
                guard let self = self else {return}
                self.loaderSubject.onNext(false)
                guard let error = error as? ApiError else {
                    self.errorSubject.onNext(error.localizedDescription)
                    return
                }
                self.errorSubject.onNext(error.message)
            }
            .disposed(by: disposeBag)
    }
    
    func manageFetchedProfiles(profiles: [ProfileModel]){
        if profiles.count < self.pageSize {
            self.isLastPage = true
        }
        modelsBehaviourRelay.accept(modelsBehaviourRelay.value + profiles.map{.init($0)})
    }
    
    func pullToRefresh() {
        reset()
        search()
    }
    
    func reset() {
        pageNumber = 1
        modelsBehaviourRelay.accept([])
    }
    
    func nextPage() {
        if !isLastPage && !isLoading {
            pageNumber += 1
            search()
        }
    }
    
}
