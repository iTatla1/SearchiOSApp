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
        
        XCTAssertTrue(dataStore.messages.count == 0)
    }
    
    func test_viewModel_changingSearchTriggersSearchRequest() {
        let dataStore = GitHubDataStoreSpy()
    
        var viewModel = makeSUT(dataStore: dataStore)
        viewModel.searchString = "Dummy Search String"
        
        XCTAssertTrue(dataStore.messages.count == 1)
    }
    
    func test_viewModel_changingSearchTriggerRequestWithCorrectQuery() {
        let dataStore = GitHubDataStoreSpy()

        let searchString = "Search String"
        var viewModel = makeSUT(dataStore: dataStore)
        viewModel.searchString = searchString

        XCTAssertEqual(dataStore.messages[0].search, searchString)
    }
    
    func test_viewModel_changingSearchRequestsWithCorrectPagination() {
        let dataStore = GitHubDataStoreSpy()
        
        let pageNumber: Int = 1
        let pageSize: Int = 9
        let isLastPage: Bool = false
        let pagination = PagingController(pageNumber: pageNumber, pageSize: pageSize, isLastPage: isLastPage)
        
        let searchString = "Search String"
        var viewModel = makeSUT(dataStore: dataStore, pagingController: pagination)
        viewModel.searchString = searchString
        
        XCTAssertEqual(dataStore.messages[0].search, searchString)
        XCTAssertEqual(dataStore.messages[0].pageNumber, pageNumber)
        XCTAssertEqual(dataStore.messages[0].pageSize, pageSize)
        
    }
    
    func test_viewModel_OnLastPageDoestNotRequestSearch() {
        let dataStore = GitHubDataStoreSpy()
        let paginationController = PagingController()
        
        // Called search first time
        let searchString = "Search String"
        var viewModel = makeSUT(dataStore: dataStore, pagingController: paginationController)
        XCTAssertFalse(paginationController.isLastPage)
        viewModel.searchString = searchString
        XCTAssertTrue(dataStore.messages.count == 1)
        
        //Calling Again
        XCTAssertTrue(paginationController.isLastPage)
        
        //Doesnot fetched search again
        XCTAssertTrue(dataStore.messages.count == 1)
    }
    
    
    func test_viewModel_NextPageOnSearch() {
        
        let dataStore = GitHubDataStoreSpy()
        dataStore.stubbed = [
        ProfileModel(name: "A name", type: "A type", imageURL: URL(string: "http://www.anyURL.com")!),
        ProfileModel(name: "A name", type: "A type", imageURL: URL(string: "http://www.anyURL.com")!)
        ]
        let paginationController = PagingController(pageNumber: 1, pageSize: 1)
        
        
        // Called search first time
        let searchString = "Search String"
        var viewModel = makeSUT(dataStore: dataStore, pagingController: paginationController)
        viewModel.searchString = searchString
        XCTAssertTrue(dataStore.messages.count == 1)
        XCTAssertFalse(paginationController.isLastPage)
        
        
        // Calling Next Page
        viewModel.nextPage()
        XCTAssertTrue(dataStore.messages.count == 2)
        XCTAssertFalse(paginationController.isLastPage)
    
        // Calling third time should now paging controller be false
        viewModel.nextPage()
        
        //Doesnot fetched search again
        XCTAssertTrue(dataStore.messages.count == 3)
        XCTAssertTrue(paginationController.isLastPage)
    }
    
    func test_viewModel_OnConnectivityErrorThrowsConnectivityErrorMessage() {
        
        let dataStore = GitHubDataStoreSpy()
        dataStore.stubbedError = ApiError.connectivity
        
        let errorSubject = PublishSubject<String>()
        
        let expectation = expectation(description: "Wait for async code tofinish.")
        
        errorSubject.asObservable()
            .subscribe { message in
                XCTAssertEqual(message, ApiError.connectivity.message)
                expectation.fulfill()
            } onError: { _ in}
            .disposed(by: disposeBag)

        // Called search first time
        let searchString = "Search String"
        var viewModel = makeSUT(dataStore: dataStore, errorSubject: errorSubject)
        viewModel.searchString = searchString
        XCTAssertTrue(dataStore.messages.count == 1)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_viewModel_OnInValidDataErrorThrowsInvalidDataErrorMessage() {
        
        let dataStore = GitHubDataStoreSpy()
        dataStore.stubbedError = ApiError.invalidData
        
        let errorSubject = PublishSubject<String>()
        
        let expectation = expectation(description: "Wait for async code tofinish.")
        
        errorSubject.asObservable()
            .subscribe { message in
                XCTAssertEqual(message, ApiError.invalidData.message)
                expectation.fulfill()
            } onError: { _ in}
            .disposed(by: disposeBag)

        // Called search first time
        let searchString = "Search String"
        var viewModel = makeSUT(dataStore: dataStore, errorSubject: errorSubject)
        viewModel.searchString = searchString
        XCTAssertTrue(dataStore.messages.count == 1)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_viewModel_OnLoadingDoesNotCallSearch() {
        
        let dataStore = GitHubDataStoreSpy()
        let searchString = "Search String"
        var viewModel = makeSUT(dataStore: dataStore)
        viewModel.loaderSubject.onNext(true)
        viewModel.searchString = searchString
        XCTAssertTrue(dataStore.messages.count == 0)
        
        
    }
    
    func test_viewModel_emptySearchStringDoesNotCallSearch() {
        
        let dataStore = GitHubDataStoreSpy()
        let emptySearchString = ""
        var viewModel = makeSUT(dataStore: dataStore)
        viewModel.searchString = emptySearchString
        XCTAssertTrue(dataStore.messages.count == 0)
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
        var messages: [(search: String, pageNumber: Int, pageSize: Int)] = []
        
        var stubbed: [ProfileModel]?
        var stubbedError: ApiError?
        
        func fetchUsers(search: String, pageNumber: Int, pageSize: Int) -> Single<[ProfileModel]> {
            messages.append((search, pageNumber, pageSize))
    
            if let stubbedError = stubbedError {
                return Single.create { single in
                    single(.failure(stubbedError))
                    return Disposables.create()
                }
            }
            
            
            if let stubbed = stubbed{
                if stubbed.count >= pageSize {
                    let first = Array(stubbed.prefix(pageSize))
                    self.stubbed = stubbed.dropLast(pageSize)
                    return Observable.just(first).asSingle()
                }
                else {
                    let observable: Observable<[ProfileModel]> = Observable.just(stubbed)
                    self.stubbed = nil
                    return observable.asSingle()
                }
                
            }
            else{
                return Observable.just([]).asSingle()
            }
           
        }
    }
}
