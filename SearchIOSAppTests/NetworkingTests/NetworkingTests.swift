//
//  NetworkingTests.swift
//  SearchIOSAppTests
//
//  Created by Muhammad Usman Tatla on 12/12/21.
//

import XCTest
import Moya
import RxTest
import RxSwift

@testable import SearchIOSApp

class NetworkingTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    //
        override func setUp() {
            super.setUp()
            disposeBag = DisposeBag()
        }
    
    override func tearDown() {
        disposeBag = nil
       super.tearDown()
    }
    
    func test_OnFetch_returnsConnectivtyErrorOnNon200HTTPResponses() {
        var expectations = [XCTestExpectation]()
        [199, 300, 400, 500].enumerated().forEach { index, code in
            let sut = makeSUT(for: code, data: anyData())
            let expectation = expectation(description: "Wait for async Code")
            sut.fetchUsers(search: "23", pageNumber: 1, pageSize: 12)
                .subscribe { _ in
                    XCTFail("Expected to fail with connectivity error")
                } onFailure: { error in
                    guard let error = error as? ApiError else {
                        XCTFail("Expected to fail with API Error connectivity error")
                        return
                    }
                    XCTAssertEqual(ApiError.connectivity, error)
                    expectation.fulfill()
                }
                .disposed(by: disposeBag)
            expectations.append(expectation)
            
        }
        wait(for: expectations, timeout: 1)
    }
    
    // MARK: - Helper Methods
    
    private func makeSUT(for code: Int, data: Data) -> GitHubDataStore {
        let endPointStatusClosure = endPointClosureWithCode(statusCode: code, data: data)
        let provider = MoyaProvider<GitHub>(endpointClosure: endPointStatusClosure, stubClosure: MoyaProvider.immediatelyStub)
        
        let store = GitHubDataStoreImpl(provider: provider)
        return store
    }
    
    private func endPointClosureWithCode(statusCode: Int, data: Data) -> (GitHub) -> Endpoint {
        return { (target: GitHub) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(statusCode, data) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
    }
    
    private func anyData() -> Data {
        return Data()
    }
    
    
    
}
