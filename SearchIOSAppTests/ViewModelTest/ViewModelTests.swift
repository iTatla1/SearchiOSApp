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
        let loaderSubject = PublishSubject<Bool>()
        let errorLoader = PublishSubject<String>()
        let models = BehaviorRelay<[CellViewModel]>(value: [])
        let pagingController = PagingController()
        
        let _ = VCViewModelImpl(dataStore: dataStore, loaderSubject: loaderSubject, errorSubject: errorLoader, modelsBehaviour: models, pagingController: pagingController)
        
        XCTAssertTrue(dataStore.callBackCount == 0)
    }
    
    
    // MARK: - Helpers
    
    private class GitHubDataStoreSpy: GitHubDataStore {
        var callBackCount: Int = 0
        
        func fetchUsers(search: String, pageNumber: Int, pageSize: Int) -> Single<[ProfileModel]> {
            callBackCount += 1
    
            return Observable.just([]).asSingle()
        }
    }
    
    
}
