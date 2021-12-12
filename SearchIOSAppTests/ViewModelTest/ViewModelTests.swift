//
//  ViewModelTests.swift
//  SearchIOSAppTests
//
//  Created by Muhammad Usman Tatla on 12/12/21.
//

import XCTest
import RxSwift
import RxCocoa
@testable import SearchIOSApp

class ViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func test_viewModel_initalizationDoNotIntiateSearchRequest() {
        let dataStore = GitHubDataStoreSpy()
    
        let _ = makeSUT(dataStore: dataStore)
        
        XCTAssertTrue(dataStore.callBackCount == 0)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(dataStore: GitHubDataStore,
                         loaderSubject: PublishSubject<Bool> = PublishSubject<Bool>(),
                         errorSubject: PublishSubject<String> = PublishSubject<String>(),
                         modelsBehaviour: BehaviorRelay<[CellViewModel]> = BehaviorRelay<[CellViewModel]>(value: []),
                         pagingController: PagingController =  PagingController()) -> VCViewModel {
        return VCViewModelImpl(dataStore: dataStore, loaderSubject: loaderSubject, errorSubject: errorSubject, modelsBehaviour: modelsBehaviour, pagingController: pagingController)
    }
    
    private class GitHubDataStoreSpy: GitHubDataStore {
        var callBackCount: Int = 0
        
        func fetchUsers(search: String, pageNumber: Int, pageSize: Int) -> Single<[ProfileModel]> {
            callBackCount += 1
    
            return Observable.just([]).asSingle()
        }
    }
    
    
}
