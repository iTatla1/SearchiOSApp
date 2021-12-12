//
//  ViewModel.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import Foundation
import RxSwift
import RxCocoa

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
    
    private let pagingController: PagingController
    private var loadingRelay = BehaviorRelay<Bool>(value:false)
    private let dataStore: GitHubDataStore
    private let disposeBag = DisposeBag()
    private let modelsBehaviourRelay: BehaviorRelay<[CellViewModel]>
    
    var isLoading: Bool {
        loadingRelay.value
    }
    
    init(
        dataStore: GitHubDataStore,
        loaderSubject: PublishSubject<Bool> = PublishSubject<Bool>(),
        errorSubject: PublishSubject<String> = PublishSubject<String>(),
        modelsBehaviour: BehaviorRelay<[CellViewModel]> = BehaviorRelay<[CellViewModel]>(value: []),
        pagingController: PagingController =  PagingController()
    ){
        self.dataStore = dataStore
        self.loaderSubject = loaderSubject
        self.errorSubject = errorSubject
        self.modelsBehaviourRelay = modelsBehaviour
        self.searchString = ""
        self.pagingController = pagingController
        
        loaderSubject.bind(to: loadingRelay).disposed(by: disposeBag)
    }


    
    func search() {
        if (pagingController.isLastPage || isLoading || searchString.isEmpty) { return }
        
        loaderSubject.onNext(true)
        dataStore.fetchUsers(search: searchString, pageNumber: pagingController.pageNumber, pageSize: pagingController.pageSize)
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
        if profiles.count < self.pagingController.pageSize {
            self.pagingController.isLastPage = true
        }
        modelsBehaviourRelay.accept(modelsBehaviourRelay.value + profiles.map{.init($0)})
    }
    
    func pullToRefresh() {
        reset()
        search()
    }
    
    func reset() {
        pagingController.reset()
        modelsBehaviourRelay.accept([])
    }
    
    func nextPage() {
        _ = pagingController.nextPage()
        search()
    }
    
}
